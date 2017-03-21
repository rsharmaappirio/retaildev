
(function (app) {


  // Question Data Format...
  //
  //     Field Name          Sample Value                          Label in Salesforce UI
  //     -------------------------------------------------------------------------------------
  //     id:                 'a4dK00000000JBX'                     Salesforce ID
  //     surveyId:           'a2dK00000000JBW'                     DMS Survey
  //     nextId:             'a5dK00000000JBS'                     NEXT Question
  //     parentId:           'a3dK00000000JBR'                     Parent Question
  //     name:               'Q-0027'                              DMS Question Name
  //     conditionalAnswer:  'NO'                                  Conditional Answer
  //     text:               Do you like?                          Question Text
  //     type:               Text/Price/Count/Select/Multi-Select  Question Type
  //     answers:            'Yes,No'                              Answer Options
  //     commentsLabel:      'Comments'                            Label for Add'l Comments
  //     createdBy:          'Matt Smith, 11/5/2013 1:55 PM'       Created By
  //     updatedBy:          'Matt Smith, 11/5/2013 1:57 PM'       Last Modified By



  var salesforce = app.salesforce = {}


  // Fetch all the survey questions (and survey name)
  salesforce.fetchAll = function (surveyID,callback) {
    //console.log('TODO: Salesforce Load All (questions and survey)')
    surveyID = surveyID || null;

    Visualforce.remoting.Manager.invokeAction(
        _CONTROLLER_GETSURVEY_ACTION,
        surveyID,
            function(result, event){
                if (event.status) {

                  callback(null,result);

                } else  {
                  callback(event.message,null);
                }
            },
            {escape: false}
        );

    /*
    fakeDataLoading(function (err, data) {
      // After data is loaded, populate the UI
      callback(err, data)
    })
    */

  }



  // Create a new question in Salesforce
  // data contains fields values -> {text: 'What is happening?', ...}
  salesforce.createQuestion = function (data, callback) {
    if(!data){
      callback('No question provided.');
      return;
    }
    if(!data.surveyId){
      callback('No survey ID provided.');
      return;
    }

    //default the text - this was screwing up Question relationships
    if(!data.text){
      data.text = 'Enter Question Here';
    }

    //console.log('TODO: Salesforce Create ' + JSON.stringify(data))
    Visualforce.remoting.Manager.invokeAction(
        _CONTROLLER_UPSERTQUESTION_ACTION,
        data,
            function(result, event){
                if (event.status) {
                  callback(null,result);

                } else  {
                  callback(event.message,null);
                }
            },
            {escape: false}
        );
    /*
    // Assign an id - because that's what salesforce will do for a new record
    data.id = Math.random().toString().replace('.', '')

    // Fake delay to emulate talking to salesforce
    setTimeout(function () {
      // Fire callback with error (if there was one) and values from database
      callback(null, data)
    },500)
    */
  }



  // Update an existing question in Salesforce
  // data contains fields values -> {id: 'a4dK00000000JBX', text: 'What is happening?', ...}
  salesforce.updateQuestion = function (data, callback) {
  	//data.answers = data.answers.replace("'","\\'");
    console.log('TODO: Salesforce Save ' + JSON.stringify(data))
    if(!data){
      callback('No question provided.');
      return;
    }


    Visualforce.remoting.Manager.invokeAction(
        _CONTROLLER_UPSERTQUESTION_ACTION,
        data,
            function(result, event){
                if (event.status) {
                  callback(null,result);
                } else  {
                  callback(event.message,null);
                }
            },
            {escape: false}
        );

    /*
    // Fake delay to emulate talking to salesforce
    setTimeout(function () {
      // Fire callback with error (if there was one) and updated values from database
      callback(null, data)
    },500)
    */
  }



  // Delete a question from Salesforce
  salesforce.removeQuestion = function (id, callback) {
    //console.log('TODO: Salesforce Remove ' + id)

    Visualforce.remoting.Manager.invokeAction(
        _CONTROLLER_REMOVEQUESTION_ACTION,
          id || null,
              function(result, event){
                  if (event.status) {
                    callback(null);

                  } else  {
                    callback(event.message);
                  }
              },
              {escape: false}
          );


    /*
    // Fake delay to emulate talking to salesforce
    setTimeout(function () {
      // Fire callback with error and the id of the record that was removed
      callback(null, id)
    },500)
    */
  }



  // Update the survey with the id of the first question.
  // NOTE: The id will be null if there is no first question.
  salesforce.setFirstQuestion = function (id, callback) {
    //console.log('TODO: Salesforce Set First Question ID: ' + id)

    Visualforce.remoting.Manager.invokeAction(
        _CONTROLLER_SETFIRSTQUESTION_ACTION,
          id || null,
              function(result, event){
                  if (event.status) {
                    callback(null);

                  } else  {
                    callback(event.message);
                  }
              },
              {escape: false}
          );
    /*
    // Fake delay to emulate talking to salesforce
    setTimeout(function () {
      // Fire callback with error and the id of the record that was removed
      callback(null, id)
    },500)
    */
  }


/*
  // TODO: Remove this fake (data loading) function
  fakeDataLoading = function(callback) {
    setTimeout(function () {
      var fakeData = {
        surveyName: 'My Survey',
        questions: [

          {id: 'Q1', nextId: 'Q2',   text: 'Question #1',    type: 'Price'},
          {id: 'Q2', nextId: 'Q3',   text: 'Question #2',    type: 'Select',      answers: 'Yes,No'},
          {id: 'Q2-1', parentId: 'Q2', text: 'Follow up Question?', type: 'Multi-Select', answers: 'Up,Down,Both', conditionalAnswer: 'YES'},
          {id: 'Q3', nextId: 'Q4',     text: 'Question #3',    type: 'Text'},
          {id: 'Q4',                 text: 'Question #4',    type: 'Count'},
        ]
      }

      callback(null, fakeData)
    }, 500)
  }
*/

})( typeof module !== 'undefined' ? module.exports : window )

