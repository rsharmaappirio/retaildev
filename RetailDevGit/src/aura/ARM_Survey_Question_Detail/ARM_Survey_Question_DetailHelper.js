/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_Question_DetailHelper.js
 * Description: Helper for ARM_Survey_Question_DetailController
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  ===================================================================== */

({

    CHUNK_SIZE: 900000,
    setFileNone: function(component, event) {
        var src = event.srcElement;
        $(src).val(null);
        component.set('v.currentImage', '');
    },

    getSurveyQuestions: function(component, event) {
        var surveyId = component.get("v.surveyId");
        var action = component.get("c.getQuestions"); // method in the apex class
        var self = this;
        action.setParams({
            "surveyId": surveyId
        });
        action.setCallback(this, this.getSurveyQuestions_callback(component));
        $A.enqueueAction(action);
    },

    getSurveyQuestions_callback: function(component) {
        return (function(a) {
            if (a.getState() == "SUCCESS") {
                var question_detail_list_json = jQuery.parseJSON(a.getReturnValue());
                //set component attributes
                this.loadData(component, question_detail_list_json, question_detail_list_json.firstQuestionId);
            } else {
                //if there is any error, show that
                this.notifyErrors(a);
            }
        });
    },

    //set the attributes in component
    loadData: function(component, question_detail_list_json, firstQuestionId) {
        component.set("v.surveyName", question_detail_list_json.surveyName);
        component.set("v.questions_list", question_detail_list_json);
        //set the value of question_detail in component
        component.set("v.question_detail", question_detail_list_json.parentQuestions[firstQuestionId]);
        component.set("v.total_questions", Object.keys(question_detail_list_json.parentQuestions).length);
        component.set("v.dependentQuestionsMap", question_detail_list_json.dependentQuestionsMap);
    },

    radioButtonHandler: function(component, event) {
        var question = component.get("v.question_detail");
        var answerList = question.answer_options;
        var selectedRadio = event.getSource();
        var allRadiosArr = component.find('selectRadioOption');

        for (var indx = 0; indx < allRadiosArr.length; indx++) {
            var radioCmp = allRadiosArr[indx];
            if (radioCmp.isRendered() && selectedRadio.getGlobalId() != radioCmp.getGlobalId()) {
                radioCmp.set('v.value', false);
            }
        }
    },

    validateSelectOrMultiSelect: function(component, question_type) {
        var validation_result = {};
        var isSelected = false;
        //check if any one of radio or select is selected or not       
        if (question_type == 'Select') {

            var allRadiosArr = component.find('selectRadioOption');
            for (var indx = 0; indx < allRadiosArr.length; indx++) {
                var radioCmp = allRadiosArr[indx];
                if (radioCmp.isRendered() && radioCmp.get('v.value') == true) {
                    isSelected = true;
                    break;
                }
            }
        } else {
            var allCheckboxesArr = component.find('selectCheckboxOption');
            for (var indx = 0; indx < allCheckboxesArr.length; indx++) {
                var checkBoxCmp = allCheckboxesArr[indx];
                if (checkBoxCmp.isRendered() && checkBoxCmp.get('v.value') == true) {
                    isSelected = true;
                    break;
                }
            }
        }

        //if validation successful, return success
        if (isSelected) {
            validation_result.status = 'SUCCESS';
            validation_result.msg = 'SUCCESS';
        }
        //else return fail
        else {
            validation_result.status = 'FAIL';
            validation_result.msg = 'You must choose an Option.';
        }
        return validation_result;
    },

    validateTextPriceCount: function(component, question_type) {
        var validation_result = {};
        var numberOrPriceVal = component.get("v.question_detail.answer");
        if (numberOrPriceVal == null || numberOrPriceVal == '') {
            validation_result.status = 'FAIL';
            validation_result.msg = 'Answer cannot be empty';
        } else if (isNaN(numberOrPriceVal) && question_type != 'Text') {
            validation_result.status = 'FAIL';
            validation_result.msg = 'Please enter valid Number';
        } else {
            validation_result.status = 'SUCCESS';
            validation_result.msg = 'SUCCESS';
        }

        return validation_result;
    },

    //validate if answer is selected or not
    validateAnswer: function(component, question_type) {
        var validation_result = {};
        var question = component.get("v.question_detail");

        if (typeof question.getanswer != 'undefined') {
            console.log('>>question.getAnswer', question.getanswer());
        }
        //if question is of type single select or multi select
        if (question_type == 'Select' || question_type == 'Multi-Select') {
            validation_result = this.validateSelectOrMultiSelect(component, question_type);
        }
        //if question is of type number or price
        if (question_type == 'Count' || question_type == 'Price' || question_type == 'Text') {
            validation_result = this.validateTextPriceCount(component, question_type);

        }
        //if question requires a photo
        //check if photo is attached
        //if not , throw the error
        //
        if (question.question.Require_Photos__c) {
            if (question.photos.length == 0) {
                validation_result.status = 'FAIL';
                validation_result.msg = 'Photo is mandatory here. Please attach.';
            }
        }
        if (validation_result.status == 'FAIL') {
            this.toggleSpinnerCSS(component, event);
        }
        return validation_result;
    },

    // function to notify if any errors comes
    notifyErrors: function(a) {
        //show some error messages
        var errors = a.getError();
        if (errors) {
            $A.log("Errors", errors);
            if (errors[0] && errors[0].message) {
                $A.error("Error message: " +
                    errors[0].message);
            }
        } else {
            $A.error("Unknown error");
        }
    },

    goToSummaryPage: function(component, event, helper) {
        console.log(component.get("v.selectedQuestions"));
        component.set("v.showSummary", true);
    },



    previewImage: function(component, event) {
        var question = component.get("v.question_detail");
        var answerPhotos = question.photos;
        var answerPhotos = [];
        component.set("v.question_detail.photos", '');
        var MAX_FILE_SIZE = 4350000;

        var src = event.srcElement;
        var imgFiles = src.files;
        var allImages = component.get("v.allImages");

        var currentImage = {};
        if (imgFiles[0].size > MAX_FILE_SIZE) {
            console.log('File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' +
                'Selected file size: ' + imgFiles[0].size);
            return;
        }
        if (imgFiles != null && imgFiles.length > 0) {
            if (src.files[0].type.indexOf("image/") == 0) {
                var imgURL = URL.createObjectURL(imgFiles[0]);
            }
            //console.log(imgFiles[0]);
            //set the base 64 of image in questions photo variable array and url in image

            var fr = new FileReader();
            fr.onload = this.fileReader_OnLoad(component, fr, currentImage, answerPhotos, question);
            fr.readAsDataURL(imgFiles[0]);
        }
    },

    fileReader_OnLoad: function(component, fr, currentImage, answerPhotos, question) {

        return (function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
            var imgBASE64 = encodeURIComponent(fileContents);
            //currentImage.imgString = imgBASE64;
            currentImage.imgString = fileContents;
            currentImage.queId = question.question.Id;
            answerPhotos.push(imgBASE64);
            question.photos = answerPhotos;
            component.set("v.question_detail", question);
            component.set("v.currentImage", currentImage);

        });
    },

    upload: function(component, event) {

        var fromPos = 0;
        var fileContents = component.get("v.currentImage");
        var toPos = Math.min(fileContents.imgString.length, fromPos + this.CHUNK_SIZE);
        // start with the initial chunk
        this.uploadChunk(component, 'SurveyResultPhotosAttachment', 'image/jpeg', fileContents.imgString, fromPos, toPos, '', fileContents.queId, 1, event);
    },

    uploadChunk: function(component, fileName, fileType, fileContents, fromPos, toPos, attachId, parentId, chunkNo, event) {
        var action = component.get("c.saveTheChunk");
        var chunk = fileContents.substring(fromPos, toPos);
        //var CHUNK_SIZE = 900000; /* Use a multiple of 4 */
        var isLastChunk = Math.ceil(fileContents.length / this.CHUNK_SIZE) == chunkNo ? true : false;
        //console.log('parentId:::' + parentId);
        //console.log('isLastChunk::' + isLastChunk);
        try {
            action.setParams({
                parentId: parentId,
                fileName: fileName,
                base64Data: encodeURIComponent(chunk),
                contentType: fileType,
                fileId: attachId,
                isLastChunk: isLastChunk
            });
        } catch (e) {
            console.log('Exception:::' + e);
        }

        action.setCallback(this, this.saveTheChunk_Callback(component, isLastChunk, fileName, fileType, fileContents, fromPos, toPos, attachId, parentId, chunkNo, event));
        $A.enqueueAction(action);

    },

    saveTheChunk_Callback: function(component, isLastChunk, fileName, fileType, fileContents, fromPos, toPos, attachId, parentId, chunkNo, event) {
        return (function(a) {
            console.log('in callback');
            var state = a.getState();
            if (state === "SUCCESS") {
                attachId = a.getReturnValue();
                console.log('attachId:::' + attachId);
                console.log('isLastChunk::::' + isLastChunk);
                if (isLastChunk) {
                    var question = component.get("v.question_detail");
                    var imageURLs = question.imageURLs;
                    imageURLs.push(attachId);
                    component.set('v.question_detail', question);
                    component.set("v.currentImage", '');
                    var helper = this;
                    setTimeout(
                        $A.getCallback(function() {
                            if (component.isValid()) {
                                helper.renderNextComponent(component, event);
                            }

                        }), 2000);
                    return;
                }
                console.log('isLastChunk::::' + isLastChunk);
                fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
                chunkNo++;
                if (fromPos < toPos) {
                    console.log('uploadChunk called again');
                    this.uploadChunk(component, fileName, fileType, fileContents, fromPos, toPos, attachId, parentId, chunkNo);
                }
            } else {
                console.log('error :::' + a.getReturnValue());
            }
        });
    },

    //fire the event 
    //app will catch it and will show the component passed as "Comp_to_Load" attribute
    surveyListRedirect: function(component, event) {
        var changeCompEvent = $A.get("e.c:ARM_ChangeComponent");
        var questions_list = component.get("v.questions_list");
        var accId = component.get("v.accId");
        console.log('>>>>>accId' + accId);
        changeCompEvent.setParams({
            "Comp_to_Load": 'ARM_Survey_List',
            "accId": accId
        });
        changeCompEvent.fire();
    },

    accountListRedirect: function(component, event) {
        var changeCompEvent = $A.get("e.c:ARM_ChangeComponent");
        changeCompEvent.setParams({
            "Comp_to_Load": 'ARM_Account_List'
        });
        changeCompEvent.fire();
    },

    questionDetailRedirect: function(component, event) {
        component.set("v.showSummary", false);
        var question_detail_list_json = component.get("v.questions_list");
        if (question_detail_list_json != null) {
            //set component attributes
            this.loadData(component, question_detail_list_json, question_detail_list_json.firstQuestionId);
        }
        component.set("v.selectedQuestions", '');
        component.set("v.question_number", 1);
    },

    getSelectedAnswerRadio: function(component) {
        var selectedAnswer = '';
        var allRadiosArr = component.find('selectRadioOption');
        var indx1 = 0;
        for (var indx = 0; indx < allRadiosArr.length; indx++) {
            var radioCmp = allRadiosArr[indx];
            if (radioCmp.isRendered()) indx1++;
            if (radioCmp.isRendered() && radioCmp.get('v.value') == true) {
                selectedAnswer = radioCmp.get('v.text');
            }
        }
        console.log(indx1);
        console.log('selectedAnswer:' + selectedAnswer);


        return selectedAnswer;

    },

    getSelectedAnswersMultiSelect: function(component) {
        var selectedMulti = '';
        var allCheckboxesArr = component.find('selectCheckboxOption');
        for (var indx = 0; indx < allCheckboxesArr.length; indx++) {
            var checkboxCmp = allCheckboxesArr[indx];
            if (checkboxCmp.isRendered() && checkboxCmp.get('v.value') == true) {
                selectedMulti += checkboxCmp.get('v.text') + ';';
            }
        }

        return selectedMulti;
    },

   /* fetchNextQuestionId: function(component, selectedAnswer, selectedMulti) {
        var nextQuestionId;
        var currentQuestion = component.get("v.question_detail");
        var conditionalQuestionsMap = component.get("v.dependentQuestionsMap");
        //check if has conditional question
        if (conditionalQuestionsMap !== undefined && conditionalQuestionsMap != null && conditionalQuestionsMap[currentQuestion.question.Id] !== undefined) {
            var thisQuestionConditionalQuestion = conditionalQuestionsMap[currentQuestion.question.Id];
            //if it is radio only(Single select)
            if (selectedAnswer != null && selectedAnswer != '') {
                //if have conditional question, the the id of first conditional question
                if (thisQuestionConditionalQuestion[selectedAnswer] !== undefined && thisQuestionConditionalQuestion[selectedAnswer] != null) {
                    nextQuestionId = thisQuestionConditionalQuestion[selectedAnswer].question.Id;
                }
            }
            //if it is checkbox (multiselect)
            if (selectedMulti != null && selectedMulti != '') {
                var selectedAnswersList = selectedMulti.split(';');
                for (var x = 0; x < selectedAnswersList.length; x++) {
                    if (thisQuestionConditionalQuestion[selectedAnswersList[x]] !== undefined && thisQuestionConditionalQuestion[selectedAnswersList[x]] != null) {
                        var nextQuestion = thisQuestionConditionalQuestion[selectedAnswersList[x]].question;
                        if (!nextQuestion.isDone) {
                            nextQuestionId = nextQuestion.Id;
                            break;
                        }
                    }
                }
                if (nextQuestionId === undefined)
                    nextQuestionId = this.getNextQuestionId(conditionalQuestionsMap, questions_list, currentQuestion.question.Id);
            }
        } else {
            //if there is not next question for it but have parent, go through parents and get next question id of first parent that have next question
            if (currentQuestion.question.NEXT_Question__c == null && currentQuestion.question.Parent_Question__c != null) {
                nextQuestionId = this.getNextQuestionId(conditionalQuestionsMap, questions_list, currentQuestion.question.Id);
            } else {
                //else get its next question id.
                nextQuestionId = currentQuestion.question.NEXT_Question__c;
            }
        }
		console.log('>>>>>>>>>>nextQuestionId' + nextQuestionId);
        return nextQuestionId;
    },*/
    
    //get the next question id
    getNextQuestionId: function(conditionalQuestionsMap, questions_list, currentQuestionId) {
        var self = this;
        var Next_Question_Id = '';
        if (questions_list[currentQuestionId] !== undefined) {
            var current_Question = questions_list[currentQuestionId].question;
            if (current_Question.Parent_Question__c != null && questions_list[current_Question.Parent_Question__c] !== undefined) {
                var parentQuestion = questions_list[current_Question.Parent_Question__c];
                //if question is multiselect, check if any other option is seletec whose conditional questions are not answered yet.

                if (parentQuestion.question.Question_Type__c == 'Multi-Select') {
                    for (var x = 0; x < parentQuestion.answer_options.length; x++) {
                        if (parentQuestion !== undefined && parentQuestion.answer_options[x].value && (Next_Question_Id === undefined || Next_Question_Id == null || Next_Question_Id == '')) {
                            var parentConditionalQuestion = conditionalQuestionsMap[parentQuestion.question.Id];
                            var nextConditionalQuestion = parentConditionalQuestion[parentQuestion.answer_options[x].option];
                            if (nextConditionalQuestion !== undefined) {
                                var nextConditionalQuestionId = nextConditionalQuestion.question.Id;
                                if (nextConditionalQuestion !== undefined && nextConditionalQuestion != null && !questions_list[nextConditionalQuestionId].isDone) {
                                    Next_Question_Id = nextConditionalQuestionId;
                                }
                            }
                        }
                    }
                    //if Next question id is still null, means all the conditional questiona re answered
                    //in that case get the Next question of question
                    if (Next_Question_Id === undefined || Next_Question_Id == null || Next_Question_Id == '') {
                        Next_Question_Id = parentQuestion.question.NEXT_Question__c;
                    }
                } else {
                    Next_Question_Id = parentQuestion.question.NEXT_Question__c;
                }
                //go through all parents and check same
                if (Next_Question_Id === undefined || Next_Question_Id == null || Next_Question_Id == '') {
                    Next_Question_Id = self.getNextQuestionId(conditionalQuestionsMap, questions_list, parentQuestion.question.Id);
                }
            }
        }
        return Next_Question_Id;
    },
    



    nextHandler: function(component, event) {

        //clear the error message to remove toast
        component.set("v.errorMsg", '');

        //get data from component attributes
        var currentQuestion = component.get("v.question_detail");
        var question_type = currentQuestion.question.Question_Type__c;
        var validation_result = this.validateAnswer(component, question_type);

        //check the validations, if validating fine, go for next question
        if (validation_result.status == 'SUCCESS') {
            // save image in attachments if any
            if (component.get("v.currentImage") != '' && component.get("v.currentImage") != null) {
                this.upload(component, event);
            } else {
                this.renderNextComponent(component, event);
            }
        }

        //if validation fails, show the error message as toast message
        else {
            component.set("v.errorMsg", validation_result.msg);
        }

    },
    
    renderNextComponent: function(component, event){
           var question_number = parseInt(component.get("v.question_number"));
           var questions_list = component.get("v.questions_list").parentQuestions;
           var total_questions = component.get("v.total_questions");
           var currentQuestion = component.get("v.question_detail");
           var question_type = currentQuestion.question.Question_Type__c;
           var conditionalQuestionsMap = component.get("v.dependentQuestionsMap");
    	console.log('renderNext',currentQuestion);
        var selectedAnswer = '';

        if(question_type == 'Select') {
            
            selectedAnswer = this.getSelectedAnswerRadio(component);
        }
        
        
       
        var selectedMulti = '';
        
        if(question_type == 'Multi-Select') {
            selectedMulti = this.getSelectedAnswersMultiSelect(component);
        }
        
        //for the next questions there are few conditions,
        //1. If it has conditional question, show that
        //2. If it is a conditional question itself, show next conditional question
        //3. If it is a conditional question itself, but doesnt have next conditional question, show the next question of its parent.
        //5. If it is a conditional question itself, but doesnt have next conditional question, and even its parent doesnt have next question,traverse the next parent that has next question and show it
        //6. It is is not a conditional question, also doesnt have conditions question, show its next question
        //7. If there is no next question for itself or its parents, show the summary page.
    
    
            currentQuestion.isDone = true;
            questions_list[currentQuestion.question.Id] = currentQuestion;
            var returned_json = component.get("v.questions_list");
            returned_json.parentQuestions = questions_list;
            component.set("v.questions_list", returned_json);
            var selectedQuestions = component.get("v.selectedQuestions");
        console.log('>>>>>selectedQuestions' + selectedQuestions);
            var alreadyAddedQuestion = [];
            if(selectedQuestions === undefined)
                selectedQuestions = [];
            $.each(selectedQuestions,function(index,val){
                if(val.question !== undefined)
                	alreadyAddedQuestion.push(val.question.Id);
            })
            if($.inArray(currentQuestion.question.Id,alreadyAddedQuestion) == -1)
            	selectedQuestions.push(currentQuestion);
            component.set("v.selectedQuestions",selectedQuestions);
            var nextQuestionId ;
            
            //check if has conditional question
            if(conditionalQuestionsMap !== undefined && conditionalQuestionsMap != null && conditionalQuestionsMap[currentQuestion.question.Id] !== undefined){
                var thisQuestionConditionalQuestion = conditionalQuestionsMap[currentQuestion.question.Id];
                //if it is radio only(Single select)
                if(selectedAnswer != null && selectedAnswer!= ''){
                    //if have conditional question, the the id of first conditional question
                    if(thisQuestionConditionalQuestion[selectedAnswer]  !== undefined && thisQuestionConditionalQuestion[selectedAnswer]  != null ){
                        nextQuestionId =  thisQuestionConditionalQuestion[selectedAnswer].question.Id;
                    }
                }
                //if it is checkbox (multiselect)
                if(selectedMulti != null && selectedMulti!= ''){
                    var selectedAnswersList = selectedMulti.split(';');
                    for(var x=0;x<selectedAnswersList.length;x++){
                        if(thisQuestionConditionalQuestion[selectedAnswersList[x]]  !== undefined && thisQuestionConditionalQuestion[selectedAnswersList[x]]  != null){
                            var nextQuestion = thisQuestionConditionalQuestion[selectedAnswersList[x]].question;
                            if(!nextQuestion.isDone){
                                nextQuestionId = nextQuestion.Id;
                                break;
                            }
                        }
                    }
                    if(nextQuestionId === undefined)
                        nextQuestionId = this.getNextQuestionId(conditionalQuestionsMap,questions_list,currentQuestion.question.Id);
                }
            }
            else{
                //if there is not next question for it but have parent, go through parents and get next question id of first parent that have next question
                if(currentQuestion.question.NEXT_Question__c == null && currentQuestion.question.Parent_Question__c != null){
                    nextQuestionId = this.getNextQuestionId(conditionalQuestionsMap,questions_list,currentQuestion.question.Id);
                }
                else{
                    //else get its next question id.
                    nextQuestionId = currentQuestion.question.NEXT_Question__c;
                }
            }
            
            //if current question or its parent has next question, show it
            if(nextQuestionId !== undefined && nextQuestionId != null && nextQuestionId != ''){
                var nextQuestion = questions_list[nextQuestionId];
                //for the next question, set previous question id
                nextQuestion.question.prevQuestionId = currentQuestion.question.Id;
                component.set("v.question_detail", nextQuestion);
                component.set("v.question_number", question_number + 1);
            }
            //otherwise go to summary page
            else{
                this.goToSummaryPage(component, event, this);
            }
        
		this.toggleSpinnerCSS(component, event);

    },


    previousHandler: function(component, event) {
        //clear if there is any error message
        component.set("v.errorMsg", '');
        component.set("v.currentImage", '');

        //get data from component attributes
        var questions_list = component.get("v.questions_list").parentQuestions;
        var currentQuestion = component.get("v.question_detail");
        //get the previous question id of current question, get the question from questions_list and show it on page
        var prevQuestionId = currentQuestion.question.prevQuestionId;
        var prevQuestion = questions_list[prevQuestionId];
        //reduce question number by 1
        var question_number = parseInt(component.get("v.question_number"));
        component.set("v.question_detail", prevQuestion);
        component.set("v.question_number", question_number - 1);
    },

    async_redirectToAccList: function(component, event, helper_instance) {
        return (function() {
            //console.log('valid::', component.isValid());
            if (component.isValid()) {
                helper_instance.accountListRedirect(component, event);
            }
        });
    },

    saveSurvey_Callback: function(component, event) {
        return (function(a) {
            if (a.getState() == "SUCCESS") {
                var result = a.getReturnValue();
                console.log('result>>' + result);
                if (result == 'SUCCESS') {
                    $('#success-msg-container').show();
                    //after the success message, in 2 second redirect back to list of surveys so that he can attempt the other survey
                    // use $A.getCallback for asynchronous calls to keep the reference of 
                    // component and event.
                    setTimeout(
                        $A.getCallback(this.async_redirectToAccList(component,event,this))
                        , 2000);

                } else {
                    $A.log("Error", result);
                }
            } else {
                //if there is any error, show that
                this.notifyErrors(a);
            }
        });
    },

    saveSurvey: function(component, event) {
        var questions_list = component.get("v.questions_list");

        //removing photos base64
        //till now it was here only for the preview
        //now not sending to server
        //only sending the image URLs
        $.each(questions_list.parentQuestions, function(index, val) {val.photos = [];});
        var action = component.get("c.SaveSurveyResult"); // method in the apex class
        //var self = this;
        action.setParams({"answers": JSON.stringify(questions_list)});
        action.setCallback(this, this.saveSurvey_Callback(component, event));
        $A.enqueueAction(action);
    },

    toggleSpinnerCSS: function(component, event) {
        var changeCompEvent = $A.get("e.c:ARM_Spinner");
        changeCompEvent.fire();
    }

})