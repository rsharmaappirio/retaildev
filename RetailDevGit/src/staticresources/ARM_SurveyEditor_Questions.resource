(function (app) {


  // -------------- simple event emitter -------------------------


  function Emitter () { }


  Emitter.prototype.on = function (event, callback) {
    if (!this._events) this._events = {}
    if (!this._events[event]) this._events[event] = []
    this._events[event].push(callback)
  }


  Emitter.prototype.emit = function (event) {
    if (!this._events) this._events = {}
    var callbacks = this._events[event]
    if (!callbacks) return
    var args = Array.prototype.slice.call(arguments, 1)
    for (var i = callbacks.length - 1; i >= 0; i--) {
      callbacks[i].apply(this, args)
    }
  }


  Emitter.prototype.off = function (event, callback) {
    if (!this._events) this._events = {}
    var callbacks = this._events[event]
    if (!callbacks) return
    for (var i = callbacks.length - 1; i >= 0; i--) {
      if (callbacks[i] === callback) callbacks.splice(i, 1)
    }
  }


  // -------------- Answer classs -------------------

  var answerId = 0
  function nextAnwerId () {
    answerId += 1
    return 'A' + answerId
  }


  function Answer (props) {
    if (!props) props = {}

    this.id = nextAnwerId()

    this.props = clone(props)

    // Set defaults
    this.props.score = this.props.score || '0'
    this.props.value = this.props.value || ''
    this.props.valueBrandId = this.props.valueBrandId || ''
    this.props.goalScore = this.props.goalScore || '0'

    // Let each answer emit events
    extend(this, Emitter.prototype)
  }


  // Also allow the class to emit events
  extend(Answer, Emitter.prototype)


  Answer.prototype.get = function (field) {
    return this.props[field]
  }


  Answer.prototype.set = function (props) {
    var before = clone(this.props)
    extend(this.props, props)
    if (different(before, this.props)) {
      // Emit the event from this answer, and from the class
      this.emit('changed', this)
      Answer.emit('answerChanged', this)
    }
  }


  Answer.prototype.addAfter = function () {
    this.emit('addAfter', this)
  }


  Answer.prototype.remove = function () {
    this.emit('remove', this)
    Answer.emit('answerRemoved', this)
  }


  // ------- Default answers for a new Question -------


  var DEFAULT_ANSWERS_JSON = JSON.stringify([
    { value: 'Yes', valueBrandId : '', score: '0', goalScore: '0' },
    { value: 'No', valueBrandId : '',  score: '0', goalScore: '0' }
  ])


  // -------------- Question classs -------------------


  function Question (props) {
    if (!props) props = {}

    // Create an id if one wasn't already assigned
    var isNew = !props.id
    props.id = props.id || Question.generateId()

    // Set default values
    props.answers = props.answers || DEFAULT_ANSWERS_JSON
    props.type    = props.type    || 'Select'
    props.includeNone = props.includeNone || false;
    props.includePhotos = props.includePhotos || false;
    props.requirePhotos = props.requirePhotos || false;
    
    props.isGoal = props.isGoal || false; 
    props.goalName = props.goalName || ''; 
    props.goalType = props.goalType || '';
    props.goalBrand = props.goalBrand || undefined;
    //props.goalStartDate = props.goalStartDate || ''
    //props.goalEndDate = props.goalEndDate || ''
    props.maxGoalScore = props.maxGoalScore || '0';
    props.conditionalAnswerBrandId = props.conditionalAnswerBrandId || '';
    
    // Props are the fields that get persisted back to the database
    this.props = clone(props)

    // This id is not the one from the database.
    // It is used to bind ui to data, and to connect unsaved data.
    // The 'Q' prefix is used to make it safe as an id on an html element.
    // The id is read-only, so copy it to the instance for convenience
    this.id = this.props.id

    // Parse the JSON to get the answer data
    var answerData
    try {
      answerData = JSON.parse(props.answers)
    } catch (e) {
      // Parse the old (comma-delimited) answer format
      answerData = props.answers.split(',').map(function (answer) {
        return {
          value: answer.trim(),
          valueBrandId: '',
          score: '0',
          goalScore: '0'
        }
      })
      // Set the prop directly, to avoid firing a save during constructor
      this.props.answers = JSON.stringify(answerData)
    }

    // Attach answer objects
    this._answers = []
    for (var i = 0; i < answerData.length; i++) {
      this._answers.push(this._createAnswer(answerData[i]))
    }

    // Make sure the maxScore is set correctly
    this._updateMaxScore()

    // Tests can demand immediate "updated" events, to avoid slow tests
    if (!Question.immediateUpdates) {
      var self = this
      // Debounce to wait until user has taken a little break before saving
      this.requestSave = debounce(function () {
        Question.prototype.requestSave.apply(self, arguments)
      }, 10) //ms
    }

    Question._lookup[this.id] = this
  }


  Question.prototype.constructor = Question


  // Questions are given a new id (html safe) for use in the UI
  Question._lastId = (new Date()).valueOf()
  Question.generateId = function () {
    Question._lastId += 1
    return 'Q' + Question._lastId
  }


  // Add a lookup for finding questions
  Question._lookup = {}


  // Find a question by id (note: this is NOT the database id)
  Question.find = function (id) {
    return Question._lookup[id]
  }

  Question.findActiveQuestion = function(){
  	var activeQuestion= {};
  	$(".question").each(function( index ) {
	    var activePopup = $(this).find(".popup");
		if(activePopup.css( "display")=='block'){
			activeQuestion = Question._lookup[$(this).attr("id")];
			return false;
		}
	});
    return activeQuestion;
  }

  // Find the question with a nextId that points to this question
  Question.findPrevious = function (nextId) {
    for (var id in Question._lookup) {
      if (Question._lookup.hasOwnProperty(id)){
        var question = Question._lookup[id]
        if (question.props.nextId === nextId){
          return question;
        }
      }
    }
  }


  // Find all the questions that point to this question as their parent
  Question.findChildren = function (parentId) {
    var children = []
    for (var id in Question._lookup) {
      if (Question._lookup.hasOwnProperty(id)){
        var question = Question._lookup[id]
        if (question.props.parentId === parentId){
          children.push(question);
        }
      }
    }
    return children
  }


  // Dump data for debugging
  Question.dump = function () {
    Object.keys(Question._lookup).forEach(function (id) {
    })
  }


  // Instantiate an existing question (used when loaded from database)
  Question.load = function (props) {
    var newQuestion = new Question(props)
    Question.emit('loaded', newQuestion)

    return newQuestion
  }

  // let the Question class emit events when adding questions
  extend(Question, Emitter.prototype)


  // Postone emit until next "tick" (so `return` fires before emit)
  var originalEmit = Question.emit
  Question.emit = function () {
    var args = Array.prototype.slice.call(arguments, 0)
    setTimeout(function () { originalEmit.apply(Question, args) }, 0)
  }


  Question.prototype.set = function (props) {
    if (props.id) throw 'Setting id is not allowed'
    if (props.answers) throw 'Setting answers is not allowed'

    this._update(props)
  }
  
  Question.prototype.flushChanges = function (question) {
    // create a deferred object
    var r = $.Deferred();

    this.requestSave();
    
    setTimeout(function () {
      // and call `resolve` on the deferred object, once you're done
      r.resolve(question);
    }, 2500);

    // return the deferred object
    return r;
  };


  Question.prototype._update = function (props) {
    var before = clone(this.props)
    extend(this.props, props)

    // If the type has been set, recalculate the maxScore
    if (props.type) this._updateMaxScore()

    if (different(before, this.props)) {
      Question.emit('changed', this)
      if(props.text || props.nextId || props.conditionalAnswer){
      	this.requestSave()
      }
    }
  }


  Question.prototype.isFirst = function () {
    return !this._removed && !this.parent() && !this.previous()
  }


  Question.prototype.requestSave = function () {
    if (this._removed) return
    if (this.isFirst()) Question.emit('update-first', this)
    Question.emit('updated', this)
  }


  Question.prototype.get = function (field) {
    return this.props[field]
  }


  Question.prototype.getAnswers = function (index) {
    if (typeof index !== 'undefined') return this._answers[index]
    return this._answers
  }


  Question.prototype.getAnswerList = function (index) {
    return this._answers.map(function (a) {
      return a.get('value')
    }).join(', ')
  }


  Question.prototype.addAnswerAfter = function (answer) {
    var index = this.getAnswerIndex(answer)
    var newAnswer = this._createAnswer()
    this._answers.splice(index + 1, 0, newAnswer)
    this._refreshAnswerData()
    Answer.emit('answerAdded', newAnswer)
  }

  Question.prototype.addAnswer = function (answerProps) {
    var newAnswer = this._createAnswer(answerProps)
    this._answers.push(newAnswer)
    this._refreshAnswerData()
    Answer.emit('answerAdded', newAnswer)
  }
  
  Question.prototype.removeAnswer = function (answer) {
    var index = this.getAnswerIndex(answer)
    this._answers.splice(index, 1)
    this._refreshAnswerData()
  }


  Question.prototype.getAnswerIndex = function (answer) {
    for (var i = 0; i < this._answers.length; i++) {
      if (this._answers[i] === answer) return i
    }
  }


  Question.prototype._createAnswer = function (answerProps) {
    var self   = this
    var answer = new Answer(answerProps)

    answer.on('changed',  function (answer) { self._refreshAnswerData() } )
    answer.on('addAfter', function (answer) { self.addAnswerAfter(answer) } )
    answer.on('remove',   function (answer) { self.removeAnswer(answer) } )

    answer.question = self

    return answer
  }


  // Refresh the props on the question that relate to answer data
  Question.prototype._refreshAnswerData = function (index) {
    this._updateAnswerJSON()
    this.set({maxScore: this._getMaxScore(), maxGoalScore:this._getMaxGoalScore()})
  }


  // Refresh the JSON value with the most recent answer data
  Question.prototype._updateAnswerJSON = function (index) {
    var answerData = this._answers.map(function (answer) {
      return {
        value: answer.get('value'),
        valueBrandId: answer.get('valueBrandId').toString(),
        score: answer.get('score').toString(), // Yeah, they wanted strings
        goalScore: answer.get('goalScore').toString()
      }
    })
    this._update({answers: JSON.stringify(answerData)})
  }



  Question.prototype._updateMaxScore = function () {
    this.props.maxScore = this._getMaxScore()
    this.props.maxGoalScore = this._getMaxGoalScore()
  }


  Question.prototype._getMaxScore = function () {
    var scores = this._answers.map(function (answer) {
      var num = parseInt(answer.get('score'), 10)
      if(isNaN(num)) return 0
      return num
    })

    // On a multi-select, the max is the total
    if (this.props.type === 'Multi-Select') {
      return scores.reduce(function (total, score) { return total + score }, 0)
    }

    // On a single select, the highest score is the max
    return Math.max.apply(Math, scores)
  }
  
  Question.prototype._getMaxGoalScore = function () {
    var scores = this._answers.map(function (answer) {
      var num = parseInt(answer.get('goalScore'), 10)
      if(isNaN(num)) return 0
      return num
    })

    // On a multi-select, the max is the total
    if (this.props.type === 'Multi-Select') {
      return scores.reduce(function (total, goalScore) { return total + goalScore }, 0)
    }

    // On a single select, the highest score is the max
    return Math.max.apply(Math, scores)
  }

  Question.prototype.remove = function () {
    // Cache these values since they will change after the question is removed
    var wasFirst = this.isFirst()
    var next = this.next()

    // Remove all child questions
    var children = this.allChildren()
    for (var i = children.length - 1; i >= 0; i--) children[i].remove()

    // Remove the question from the chain of question
    this._removed = true
    this._extract()

    // Remove the question from the lookup
    delete Question._lookup[this.id]

    Question.emit('removed', this)

    // If this was the first question in the survey, update the survey
    if (wasFirst) {
      // Save the next question so it can be promoted to the first of the survey
      if (next) next.requestSave()
      else      Question.emit('update-first', null) // There is no first
    }

  }


  Question.prototype.addChild = function (props) {
    var newQuestion = new Question(props)
	//.replace(/F\d: /gi, function(matched){  return "";}) 
    // Set the conditional answer to the next available (unused) one
    var used      = this.firstBorns().map(function (q) { return q.get('conditionalAnswer').replace(/L\d: /gi,'') });
     used = used.filter(exists).map(lowercase)
    var answers   = this.getAnswers().map(function (a) { return a.get('value') })
    var available = answers.filter(function (e) { return used.indexOf(e.replace(/L\d: /gi,'').toLowerCase()) < 0 })
    newQuestion._makeChildOf(this)
    var availValue = available[0];
    availValue = availValue.replace(/L\d: /gi,'');
    newQuestion.set({conditionalAnswer: availValue})
	Question.emit('added', newQuestion)

    return newQuestion
  }


  Question.prototype.addNext = function (props) {
    var newQuestion = new Question(props)
    
	newQuestion.set({conditionalAnswerBrandId: this.props["conditionalAnswerBrandId"]})
    newQuestion._insertBetween(this, this.next())

    newQuestion.requestSave()
    Question.emit('added', newQuestion)

    return newQuestion
  }


  Question.prototype.canIndent = function () {
    return !!this.previous()
  }


  Question.prototype.canOutdent = function () {
    return !!this.parent()
  }


  Question.prototype.canMoveUp = function () {
    return !!this.previous()
  }


  Question.prototype.canMoveDown = function () {
    return !!this.next()
  }


  Question.prototype.moveBefore = function (question) {
    this._extract()
    this._insertBetween(question.previous(), question)
    Question.emit('moved', this)
    if(question) question.requestSave();
    if(question.previous()) question.previous().requestSave();
  }


  Question.prototype.moveAfter = function (question) {
    this._extract()
    this._insertBetween(question, question.next())
    Question.emit('moved', this)
    if(question) question.requestSave();
    if(question.next()) question.next().requestSave();
  }


  Question.prototype.indent = function () {
    if (!this.canIndent()) return

    var prev = this.previous()
    this._extract()
    this._makeChildOf(prev)
    Question.emit('moved', this)
    
    if(prev) prev.requestSave();
    
  }


  Question.prototype.outdent = function () {
    if (!this.canOutdent()) return

    var parent = this.parent()
    this._extract()
    this._insertBetween(parent, parent.next())
    Question.emit('moved', this)
    
    if(parent) parent.requestSave();
    if(parent.next()) parent.next().requestSave();
  }


  // Remove this question from the list by updating the nextId's
  Question.prototype._extract = function () {
    var prev = this.previous()
    var next = this.next()

    // Move the conditional answer to the next question
    if (next) next.set({conditionalAnswer: this.get('conditionalAnswer')})

    // Link the prev question to the next one
    if (prev) prev.set({nextId: this.get('nextId')})
  }


  Question.prototype._insertBetween = function (prev, next) {
    var props = {}

    if (prev) {
      props.parentId = prev.get('parentId')
      prev.set({nextId: this.id})
    }

    if (next) {
      props.parentId = props.parentId || next.get('parentId')
      props.nextId   = next.id
    } else {
      props.nextId   = undefined
    }

    this.set(props)
    
  }


  Question.prototype._makeChildOf = function (parent) {
    this.set({parentId: parent && parent.id, nextId: undefined})
  }


  Question.prototype.next = function () {
    return Question.find(this.get('nextId'))
  }


  Question.prototype.previous = function () {
    return Question.findPrevious(this.id)
  }


  Question.prototype.parent = function () {
    return Question.find(this.get('parentId'))
  }

  // Zero-based depth of this question (based on number of parents)
  Question.prototype.depth = function () {
    var depth = 0
    var q = this

    // NOTE: Intentional assignment in while(), not meant to be an equality test
    while(q = q.parent()) depth += 1

    return depth
  }


  Question.prototype.hasChildren = function () {
    return !!this.allChildren().length
  }


  Question.prototype.allChildren = function () {
    return Question.findChildren(this.id)
  }


  Question.prototype.firstBorns = function () {
    return this.allChildren().filter(function (q) {
      return q.isFirstBorn()
    })
  }


  Question.prototype.isFirstBorn = function () {
    return !!this.parent() && !this.previous()
  }

  Question.prototype.toString = function () {
    return JSON.stringify(this)
  }


  Question.prototype.toJSON = function () {
    return this.props
  }


  // Export the classes
  app.Answer   = Answer
  app.Question = Question


  // ------ basic object utility functions  ------


  function extend (target, source) {
    if (!source) return target

    for (var prop in source) {
      if (source.hasOwnProperty(prop)) {
        target[prop] = source[prop]
      }
    }
    return target
  }


  function clone (source) {
    return extend({}, source)
  }


  function different (a, b) {
    var prop
    for (prop in a) {
      if (a.hasOwnProperty(prop) && a[prop] !== b[prop]) return true
    }
    for (prop in b) {
      if (b.hasOwnProperty(prop) && a[prop] !== b[prop]) return true
    }
  }


  function debounce (fn, wait) {
    var timeout

    return function() {
      var that = this
      var args = arguments

      clearTimeout(timeout)
      timeout = setTimeout(function() { fn.apply(that, args) }, wait)
    }
  }


  function exists (s) {
    return s && s.length
  }


  function lowercase (s) {
    return s && s.toLowerCase && s.toLowerCase()
  }


})( typeof module !== 'undefined' ? module.exports : window )

