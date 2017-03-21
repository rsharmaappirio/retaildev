
(function (app) {
  dataError = {};
  // On page ready, tell salesforce to load all the data...
  $(function () {

    // During local development, fake the _SURVEY_ID
    if (window.location.href.match(/^http:\/\/localhost|file|twobitfool/)) _SURVEY_ID = 1

  //>>FL
    var surveyID = _SURVEY_ID || null;

    if(!surveyID){
      alert('No survey found');
      return;
    }
	function handleFetchAll(err, data) {
      dataError = {};
      if(err){
        try {
	        dataError = JSON.parse(err);
	    } catch (e) {
	        dataError.isError = true;
	        dataError.message = err;
	    }
        alert(err);
        return;
      }
      console.log('Initial Question Load: '+JSON.stringify(data.questions));
      loadQuestions(data.questions)
      displaySurveyName(data.surveyName)
    };
      
    app.salesforce.fetchAll(surveyID, handleFetchAll);
  //<<FL
  })


  var Question = app.Question

  // Listen to events that need to be pushed back to the database (Salesforce)
  Question.on('updated', save)
  Question.on('removed', remove)
  Question.on('update-first', updateFirst)


  function displaySurveyName (name) {
    app.ui.setSurveyName(name)
  }


  function loadQuestions (questions) {
    questions.forEach(function (data) {
      Question.load(mapIds(data))
    })
  }
  
  // All database changes are put into a queue and fired one at a time
  var pendingChanges = []


  function save (question) {
    enqueue({action: 'save', question: question})
  }


  function remove (question) {
    enqueue({action: 'remove', question: question})
  }


  // Update the survey to set the firstQuestionId
  function updateFirst (question) {
    enqueue({action: 'update-first', question: question})
  }


  // Put database request into a queue, avoid duplicates
  function enqueue (change) {
    if (alreadyQueued(change)) return

    pendingChanges.push(change)
    updateUi()
    commitNext()
  }


  function alreadyQueued (change) {
    for (var i = 0; i < pendingChanges.length; i++) {
      if (change.action === pendingChanges[i].action && change.question === pendingChanges[i].question) {
        return true
      }
    }
  }


  // Tell the UI if we are saving, or have things waiting to be saved
  function updateUi () {
    app.ui.setSaving(isBusy() || !!pendingChanges.length)
  }


  // Throttle to avoid a tidal wave of database changes
  var commitNext = throttle(firePendingChange, 100) //min ms between commits


  // Commit the next record to the database
  function firePendingChange () {
    if (isBusy()) return // don't commit more than one at a time

    var next = pendingChanges.shift()
    if (next) commit(next)
  }


  // Use a flag to prevent overlapping database requests
  var _busy
  function setBusy (busy) { _busy = busy }
  function isBusy () { return _busy }


  function commit (change) {
    if      (change.action === 'save')          saveNow(change.question)
    else if (change.action === 'remove')        removeNow(change.question)
    else if (change.action === 'update-first')  updateFirstNow(change.question)
    else    throw new Error('Invalid action: ' + change.action)
  }


  function commitDone () {
    setBusy(false)
    updateUi()
    commitNext()
  }


  function saveNow (question) {
    var data
    
	var answerText = question.props["answers"];
	question.props["answers"] = answerText.replace(/\\/g,"").replace(/'/g,"\\\\'");
    
    setBusy(true)

    try {
      var requireIds = true
      data = unmapIds(question.props, requireIds)
    } catch (e) {
      var foreignKeyMissing = e.message.match(/^No id found for/)
      // Try again later, if an id was missing on a question referenced by this one
      if (foreignKeyMissing) save(question)
      else                   console.error(e.toString())

      commitDone()
      return
    }

    // A record that has an id is existing, otherwise it is new
    if (data.id) {
      app.salesforce.updateQuestion(data, saveCallback)
    } else {
      //>>FL
      data.surveyId = _SURVEY_ID || null;
      app.salesforce.createQuestion(data, saveCallback)
      //<<FL
    }
    
    function clearMessages(questionId){
    	$("#"+ questionId + " .msgspace .srvrMessage").fadeOut().remove();
        $.each($("#"+ questionId + " :input"),function(index, object){
            $(object).css({'border':''});
        });
    }
      
    function showMessage(questionId, error){
        
        if(error){
            var errorObj = JSON.parse(error);
            // clear existing messages
            clearMessages(questionId);
            
            var srvrMessage = $('<div class="srvrMessage">'+errorObj.message+'</div>');
            $(srvrMessage).appendTo($("#"+ questionId + " .msgspace"));
            
            if(errorObj.isError){
                srvrMessage.css({'color': '#D8000C','background-color': '#FFBABA'});
            }else{
                srvrMessage.css({'color': '#4F8A10','background-color': '#DFF2BF'});
            }
            
            if(errorObj.fields){
                for(var i=0; i<errorObj.fields.length;i++){
                    $("#"+ questionId + " ." + errorObj.fields[i]).css({'border':'1px solid red'});
                }    
            }
        }
    }
      
    function saveCallback (err, newData) {
      // TODO: Handle errors
      dataError = {};
      if(err){
        try {
	        dataError = JSON.parse(err);
	    } catch (e) {
	        dataError.isError =err;
	    }
        showMessage(question.id,err);
        setBusy(false);
        ui.setSaving(false);
        return;
      }
      clearMessages(question.id);
      // Update the mappings with any newly created id
      if (!idMapping[newData.id]) idMapping[newData.id] = question.id

      // Don't try to set the id, it's read-only
      delete newData.id

	  // copying conditional answer brand id 
	  question.props['conditionalAnswerBrandId'] = newData.conditionalAnswerBrandId;
	  
      // NOTE: We do NOT update the original question with values from the database.
      //       If we did, then they could overwrite values that had been changed
      //       after the save had fired, causing it to rollback the user's changes.

      commitDone()
    }
  }


  function removeNow (question) {
    var data = unmapIds(question)
    if (!data.id) return // was never saved in the first place

    setBusy(true)

    app.salesforce.removeQuestion(data.id, function (error, id) {
   	  dataError = {};
      if(error){
      	try {
	        dataError = JSON.parse(err);
	    } catch (e) {
	        dataError.isError = true;
	        dataError.message = err;
	    }
        alert(error);
        setBusy(false);
        return;
      }
      commitDone()
      // TODO: Handle errors
    })
  }


  function updateFirstNow (question) {
    var firstQuestionId

    if (!question) {
      // If the question is missing, clear the firstQuestionId on the survey
      firstQuestionId = null
    } else {
      firstQuestionId = unmapIds(question).id

      // Wait until the question has been created
      if (!firstQuestionId) return updateFirst(question)
    }

    setBusy(true)
    app.salesforce.setFirstQuestion(firstQuestionId, function (error, id) {
      dataError = {};
      if(error){
        try {
	        dataError = JSON.parse(err);
	    } catch (e) {
	        dataError.isError = true;
	        dataError.message = error;
	    }
        alert(error);
        setBusy(false);
        return;
      }
      commitDone()
      // TODO: Handle errors
    })
  }


  // List of id fields that should be remapped
  var IS_ID = {
    'id':       true,
    'surveyId': true,
    'nextId':   true,
    'parentId': true
  }


  // Remap all of the database ids to local ids, map them back on the way out
  var idMapping = {}


  function findOrCreateId (dbId) {
    if (!dbId) return dbI
    if (!idMapping[dbId]) idMapping[dbId] = Question.generateId()
    return idMapping[dbId]
  }


  function findOriginalId (id) {
    for (var dbId in idMapping) {
      if (idMapping[dbId] === id) return dbId
    }
  }


  function mapIds (data) {
    var d = $.extend({}, data)

    for (var field in d) {
      if (d[field] && IS_ID[field]) d[field] = findOrCreateId(d[field])
    }

    return d
  }


  function unmapIds (data, requireIds) {
    var d = $.extend({}, data)

    for (var field in d) {
      if (d[field] && IS_ID[field]) {
        var dbId = findOriginalId(d[field])

        // If their is no mapping of a foreign key id, we can't save it yet
        if (requireIds && field !== 'id' && !dbId) throw new Error('No id found for ' + field + ':' + d[field])

        d[field] = dbId
      }
    }

    return d
  }


  function throttle (fn, wait) {
    if (!wait) wait = 300 // default

    var last = 0
    var timer

    return wrapper

    function wrapper () {
      var context = this
      var args    = arguments
      var now     = new Date().valueOf()
      var elapsed = now - last

      // fire the first call immediately, then only once every "wait" after that
      if (!last || elapsed > wait) {
        last = now
        fn.apply(context, args)
      } else {
        clearTimeout(timer)
        timer = setTimeout(function () { wrapper.apply(context, args) }, wait - elapsed)
      }
    }
  }


})( typeof module !== 'undefined' ? module.exports : window )
