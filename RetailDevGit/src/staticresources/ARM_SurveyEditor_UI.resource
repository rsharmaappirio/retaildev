(function (app) {


  // For IE
  if (!app.console) {
    console = {}
    console.log = function () {}
    console.error = function () {}
  }


  // ---------- inverted setTimeout (for clarity) ---------


  function wait (milliseconds, callback) {
    return setTimeout(callback, milliseconds)
  }


  // ----------------- jQuery enhancements -----------------


  $.fx.speeds._default = 300


  $.fn.scrollIntoView = function(callback) {
    var docViewTop    = $(window).scrollTop()
    var docViewBottom = docViewTop + $(window).height()
    var docViewHeight = docViewBottom - docViewTop

    var elemTop    = Math.round(this.offset().top)
    var elemBottom = Math.round(elemTop + this.height())

    var scrollTop
    var margin = 25 // pixels

    // Only scroll if it is off the screen
    if (docViewTop > elemTop - margin) {
      scrollTop = elemTop - margin
    } else if (docViewBottom < elemBottom + margin) {
      scrollTop = elemBottom + margin - docViewHeight
    } else {
      if (typeof callback === 'function') wait(0, callback)
      return this
    }

    // Adjust the duration of the scroll based on the distance
    var time = Math.abs(docViewTop - scrollTop)
    time = Math.min(time, 2000)
    time = Math.max(time, $.fx.speeds._default)

    // Need to scroll 'html' and 'body' to work across browsers
    var called
    $('html, body').finish().animate({ scrollTop: scrollTop }, time, function () {
      // Only fire the callback once
      if (called) return
      called = true
      callback()
    })

    return this
  }


  // fade a highlight (in and out)
  $.fn.pulse = function(duration) {
    var highlightBg = "#fc4"
    var originalBg  = this.css("backgroundColor")
    var animateMs   = $.fx.speeds._default
    var sleepMs     = animateMs * 3
    var $e = this

    $e.finish().animate({backgroundColor: highlightBg}, animateMs, function () {
      wait(animateMs, function () {
        $e.animate({backgroundColor: originalBg}, animateMs)
      })
    })
  }


  // -------------------------- UI methods ------------------------------


  var ui = app.ui = {}

  ui._isInvalidUI = true;
  ui.setReloadMessage = function (msgStatus) {
    ui._isInvalidUI = !msgStatus

    if (msgStatus)   $('.invalidUIMsg').slideDown()
    else             $('.invalidUIMsg').slideUp()
  }

  ui.findElement = function (question) {
    if (!question) return

    var match = $('#' + question.id)[0]
    if (!match) return

    return $(match) //wrap it back up
  }


  ui.findAnswerElement = function (answer) {
    if (!answer) return

    var match = $('#' + answer.id)[0]
    if (!match) return

    return $(match) //wrap it back up
  }


  // Find the question that is associated with the an html element
  ui.findQuestion = function (element) {
    var id = $(element).closest('.question').attr('id')
    if (!id) return
    return app.Question.find(id)
  }


  // Find the answer that is associated with the an html element
  ui.findAnswer = function (element) {
    var index = $(element).closest('.answer-row').index()
    var question = ui.findQuestion(element)

    return question.getAnswers(index)
  }


  ui.setSurveyName = function (name) {
    $('.survey .name').text(name)
    $('.loading').hide()
    ui._toggleCreateQuestionLink()
  }


  ui.setSaving = function (isSaving) {
    ui._saving = isSaving

    if (isSaving) $('.saving').slideDown()
    else          $('.saving').slideUp()
  }


  ui.fixSpacer = function ($question, animated) {
    if (!$question) return

    var question = ui.findQuestion($question)
    if (!question) return

    // Find the next question on the page
    var next = ui.findQuestion($question.next('.question'))

    var showSpacer = !next || next.depth() < question.depth()

    if      (!animated)  $question.find('.spacer').toggle(showSpacer)
    else if (showSpacer) $question.find('.spacer').slideDown()
    else                 $question.find('.spacer').slideUp()
  }


  ui.respace = function (animate) {
    if (typeof animate === 'undefined') animate = true
    $('.survey .questions .question').each(function () { ui.fixSpacer($(this), animate) })
  }


  ui.renumber = function () {
    var numbers = []
    $('.survey .questions .question').each(function () {
      var $question = $(this)
      var depth = parseInt(($question.attr('class').match(/depth-(\d+)/) || [])[1] || '0', 10)

      if (!numbers[depth]) numbers[depth] = 0
      numbers[depth] += 1
      var label = numbers.slice(0, depth + 1).join('.')

      var $number = $question.find('.number .label')
      if (!$number.text()) {
        $number.text(label)
      } else if ($number.text() !== label) {
        $number.fadeOut(function () {
          $number.text(label)
          $number.fadeIn()
        })
      }
    })
  }


  ui.updateMaxScore = function (question) {
    ui.findElement(question).find('.max-score').text(question.get('maxScore'))
     ui.findElement(question).find('.max-goal-score').text(question.get('maxGoalScore'))
  }


  ui.enableAnswerControls = function (question) {
    // The answers are only editable for select and multi-select questions
    var type = question.get('type')
    var editable = (type === 'Multi-Select' || type === 'Select')

    ui.findElement(question).find('.popup').find('.value, .score, .goalScore, .answer-button, .includeNone, .answerLevel, .generateAnswer')
      .prop('disabled', !editable)
      .toggleClass('disabled', !editable)
  }


  ui.enableDisableGoalElements = function (question){
    var goal = question.get('isGoal')
    ui.findElement(question).find('.popup').find('.goalName, .goalType, .goalScore') /*.goalBrand, .goalStartDate, .goalEndDate,*/
      .prop('disabled', !goal)
      .toggleClass('disabled', !goal)

   // ui.initDatePicker(question)
    ui.initBrandAutoSuggest(question)
    ui.initAnswerValueSuggest(question)

  }

  /*ui.initDatePicker = function(question){
  	ui.findElement(question).find('.popup').find('.goalStartDate, .goalEndDate').each(function(){
  		$(this).datepicker({minDate: 0, dateFormat: 'mm/dd/yy' });
  	})
  }*/

  var goalBrandCache = {};
  var answerBrandCache = {};

  ui.initBrandAutoSuggest = function(question){
    ui.findElement(question).find('.popup').find('.goalBrand').each(function(){
        $(this).autocomplete(
        			{minLength: 2,
        			close: function( event, ui ) {
        				event.stopPropagation();

        				$(this).change();
        			},
        			source: function( request, response ) {
	                    var term = request.term;
	                    answerBrandCache = {};
	                    if ( term in goalBrandCache ) {
	                       response( goalBrandCache[ term ] );
	                       return;
	                    }

	                    Visualforce.remoting.Manager.invokeAction(_CONTROLLER_SEARCHBRAND_ACTION, request.term,'', function(result, event){
	                          goalBrandCache[ term ] = result;
	                          response( result );
	                        },
	                        {escape: false}
	                    );
                  }});
    })
  }

  ui.initAnswerValueSuggest = function(question){
    ui.findElement(question).find('.popup').find('.answer-column .value').each(function(){
        $(this).autocomplete(
        			{minLength: 2,
        			close: function( event, ui ) {
        				event.stopPropagation()
        				$(this).keyup();
        			},
        			source: function( request, response ) {
                    	var term = request.term;
	                    if ( term in answerBrandCache ) {
	                       response( answerBrandCache[ term ] );
	                       return;
	                    }
	                    var activeQuestion = Question.findActiveQuestion();
	                    var brandLevel = activeQuestion.props["goalBrand"] || '';
	                    brandLevel = brandLevel.substring(0,2);
	                    console.log(brandLevel);
	                    Visualforce.remoting.Manager.invokeAction(_CONTROLLER_SEARCHBRAND_ACTION, request.term,brandLevel, function(result, event){

	                          answerBrandCache[ term ] = result;
	                          response( result );
	                        },
	                        {escape: false}
	                    );
                  },
                  select: function( event, ui ) {
        				$(this).prop("readonly",true);
        				$(this).css({'background-color': 'lightgray'});
        				$(this).next().css('display','block');
        			}
                  });
    })
  }

  ui.render = function (question) {
    if (!question) return

    var afterConditional = !!question.previous() && question.previous().hasChildren()

    var $question = ui.findElement(question)
    if (!$question) return

    setText('.answers .type',      function () {
      var type = question.get('type')
      if      (type === 'Multi-Select') return 'multi'
      else if (type === 'Select')      return ''
      else                             return type
    })

    setText('.answers .values',    function () {
      var type = question.get('type')
      if (type !== 'Multi-Select' && type !== 'Select') return ''

      var answers = question.getAnswerList()

      // Truncate long answers
      var max = 10
      if (answers.length > max) {
        answers = answers.substr(0, max)

        // Put an ellipses at the last space
        var end = answers.lastIndexOf(' ') + 1
        if (end <= 0) end = answers.length

        answers = answers.substr(0, end) + '...'
      }

      return answers
    })

    ui.updateMaxScore(question)
    ui.enableAnswerControls(question)
    ui.enableDisableGoalElements(question)

    setVal('.conditional .answer', 'conditionalAnswer')
    setVal('.text',                'text')
    setVal('.popup .type',         'type')

    setVal('.popup .goalName',         'goalName')
    setVal('.popup .goalType',         'goalType')
    setVal('.popup .goalBrand',         'goalBrand')
    //setVal('.popup .goalStartDate',         'goalStartDate')
    //setVal('.popup .goalEndDate',         'goalEndDate')

    $question.find('.popup .commentsLabel').val(question.get('commentsLabel'));
    $question.find('.popup .includeNone').prop('checked',question.get('includeNone'));
    $question.find('.popup .includePhotos').prop('checked',question.get('includePhotos'));
    $question.find('.popup .requirePhotos').prop('checked',question.get('requirePhotos'));
    $question.find('.popup .isGoal').prop('checked',question.get('isGoal'));

    // Look at the page (instead of just question.isFirstBorn) because the previous question might be pending removal
    var prev = ui.findQuestion($question.prevAll('.survey .question').not('.deleted').first())
    var firstConditional = question.isFirstBorn() || !!(prev && prev.depth() < question.depth())

    $question
      .toggleClass('can-indent',    question.canIndent())
      .toggleClass('can-outdent',   question.canOutdent())
      .toggleClass('can-move-up',   question.canMoveUp())
      .toggleClass('can-move-down', question.canMoveDown())
      .toggleClass('after-conditional', afterConditional)
      .toggleClass('first-conditional', firstConditional)
      .removeClass (function (index, classes) { return classes.split(' ').filter(function (className) { return className.match(/^depth-/) }).join(' ') })
      .addClass('depth-' + question.depth())


    ui.fixSpacer($question)

    function setText (selector, property) {
      var value = (typeof property === 'function') ? property() : question.get(property)
      $question.find(selector).text(value || '')
      return $question
    }


    function setVal (selector, property) {
      var $input = $question.find(selector)
      var value = question.get(property)
      // Don't change the value if the input currently has focus
      if ($input.is(':focus')) return $question
      $input.val(value || '')
      return $question
    }
  }


  ui.createQuestion = function (question) {
    var $newQuestion = $('#templates .question').clone()

    $newQuestion.attr('id', question.id)

    var previous = question.previous()
    var parent   = question.parent()

    // Insert the question after the previous questions children, if it has any
    if (previous && previous.hasChildren()) {
      // find the question that immediately follows the child questions
      var q = question
      while (!q.next() && q.parent()) {q = q.parent()}

      var $next
      if (q.next()) $next = ui.findElement(q.next())

      if ($next) {
        $newQuestion.insertBefore( $next )
      } else {
        $('.survey .questions').append($newQuestion)
      }
    } else if (previous || parent) {
      $newQuestion.insertAfter( ui.findElement(previous || parent) )
    } else if (!previous) {
      // The first question has no previous question
      $('.survey .questions').prepend($newQuestion)
    } else {
      console.error('Cannot add orphan, it has no previous question')
      console.error(question)
    }

    $newQuestion.data('focus', true)

    ui.render(question)
    ui.createAnswers(question)
    ui.updateMaxScore(question)
    ui.enableAnswerControls(question)
	ui.enableDisableGoalElements(question)

    ui._toggleCreateQuestionLink()

    if ($('.survey .question').length === 1) ui.focusFirst()

    return $newQuestion
  }


  ui.createAnswers = function (question) {
    var $question = ui.findElement(question).find('.answer-list').empty()
    question.getAnswers().forEach(function (answer) {
      ui.createAnswer(answer)
    })
  }


  ui.addAnswer = function (answer) {
    var $question = ui.findElement(answer.question)

    var prevIndex = answer.question.getAnswerIndex(answer) - 1
    var $previous = $question.find('.answer-row')[prevIndex]

    ui.createAnswer(answer, $previous)
    ui.findAnswerElement(answer).find('.value').focus()
  }


  ui.createAnswer = function (answer, $previous) {
    var $question = ui.findElement(answer.question)

    var $newAnswer = $('#templates .answer-row').clone()
    $newAnswer.attr('id', answer.id)

    $newAnswer.find('.value').val(answer.get('value'))
    if(answer.get('valueBrandId') && answer.get('valueBrandId').length>0){
    	$newAnswer.find('.value').prop("readonly",true);
    	$newAnswer.find('.value').css({'background-color': 'lightgray'})
    	$newAnswer.find('.answer-brand-buttons').css('display','block');
    }
    $newAnswer.find('.valueBrandId').val(answer.get('valueBrandId'))
    $newAnswer.find('.score').val(answer.get('score'))
    $newAnswer.find('.goalScore').val(answer.get('goalScore'))

    if ($previous) $newAnswer.insertAfter($previous)
    else           $newAnswer.appendTo($question.find('.answer-list'))

    if ($previous) $newAnswer.hide().fadeIn()
  }


  ui.addQuestion = function (question) {
    ui.flushRemovals()
    /*ui.closeAllPopups()*/

    var $newQuestion = ui.createQuestion(question)

    $newQuestion.data('focus', true)

    var $oldSpacer = $newQuestion.next('.question').find('.spacer')
    if ($newQuestion.hasClass('after-conditional')) $oldSpacer.show()

    $newQuestion.scrollIntoView(function () {
      // Animate the original spacer as this one is animated in
      if ($newQuestion.hasClass('after-conditional')) $oldSpacer.slideUp()

      $newQuestion.hide().slideDown(function () {
        $newQuestion.find('> .row .text').focus()
        $newQuestion.find('> .row .controls').pulse()
      })
    }).hide()

    ui.createAnswers(question)
    ui.renumber()
    ui.respace()
  }


  ui._toggleCreateQuestionLink = function () {
    var hasQuestions = !!$('.survey .question').not('.deleted').length

    if (hasQuestions) $('.createQuestion').hide()
    else              $('.createQuestion').fadeIn()
  }


  ui.addFirstQuestion = function () {
    ui.flushRemovals()
    Question.load({})
  }


  // show the removal, but don't actually do it, in case they want to undo
  ui.removeQuestion = function (question) {
    ui.flushRemovals()
    ui._stageRemoval(question)
    ui.updateRemovalMessage()

    if (ui._toggleTimeout) clearTimeout(ui._toggleTimeout)
    ui._toggleTimeout = setTimeout(ui._toggleCreateQuestionLink, 1000)

    var next = question.next()
    var answer = question.get('conditionalAnswer')

    // Update display of next question
    if (next) setTimeout(function () { next.set({conditionalAnswer: answer}) },1000)

    // Automatically commit the remove, if the user doesn't undo after some time
    ui._removalCountdown = setTimeout(ui.flushRemovals, 1000 * 10) //seconds
  }


  ui.removeAnswerButtonClicked = function (answer) {
    // Don't let the user delete the only answer
    if (answer.question.getAnswers().length <= 1) return
    answer.remove()
  }

  ui.removeAllAnswers = function (question) {
  	var answers = question._answers;
   	while(answers.length>0) {
   		answers[0].remove();
   	}
  }

 ui.removeAnswerValueButtonClicked = function (answer) {
    // Don't let the user delete the only answer
    ui.flushRemovals()
    var changes = {}
    changes["value"] = ''
    answer.set(changes)
    ui.render(answer.question)
    var valueInput = $.find("#"+ answer.id + ' .value')[0];

    $(valueInput).val('').prop("readonly",false).css({'background-color': ''}).keyup();
    $(valueInput).next().css('display','none')

  }

  ui.removeAnswer = function (answer) {
    var $answer = ui.findAnswerElement(answer)
    // Changed this to $(this) for Case - 00106562/DE2062  by Rahul
  //  $answer.fadeOut(function () { $(this).remove() })
    $answer.remove();
  }


  ui._stageRemoval = function (question) {
    var children = question.allChildren()
    for (var i = 0; i < children.length; i++) { ui._stageRemoval(children[i])}

    ui.queueRemoval(question)
    ui.onRemove(question)
  }


  // actually remove the questions that are "pending" removal
  ui._removals = []
  ui.flushRemovals = function (question) {
    if (ui._removalCountdown) clearTimeout(ui._removalCountdown)
    ui._removalCountdown = 0

    ui._removals.forEach(function (question) { question.remove() })
    ui._removals = []
    ui.updateRemovalMessage()
  }


  ui.queueRemoval = function (question) {
    ui._removals.push(question)
  }


  ui.undoRemovals = function () {
    var questions = $('.survey .question').map(function () { return ui.findQuestion(this) }).get().reverse()

    ui.rerenderAll(questions.concat(ui._removals))
    ui._removals.forEach(function (question) { ui.findElement(question).hide().slideDown() })

    ui._removals = []
    ui.updateRemovalMessage()
  }


  ui.updateRemovalMessage = function (pendingRemoval) {
    var count = ui._removals.length
    var $flash = $('.flash')

    if (count) {
      var message = (count === 1) ? 'Question deleted.' : count  + ' questions deleted.'

      $flash.finish().slideDown().find('.message').text(message)
    } else {
      $flash.stop().slideUp(function () { $flash.find('.message').empty() })
    }
  }


  ui.onRemove = function (question) {
    /*ui.closeAllPopups()*/

    var next      = question.next()
    var parent    = question.parent()
    var $question = ui.findElement(question)

    if (!$question) return

    $question.addClass('deleted')

    // Slight delay before hiding and removing the question
    wait($.fx.speeds._default, function () {
      $question.slideUp(function () {
        $question.remove()
        ui.renumber()
        ui.respace()
      })

      // Re-render the next question (in case it became the first conditional)
      if (next) ui.render(next)
    })
  }


  ui.focusFirst = function () {
    $('.survey .question').first().find('.text').focus()
  }


  ui.focusNextPopupControl = function () {
    var $nextAnswer     = $(':focus').closest('.answer-row').next('.answer-row').find('input:first:enabled')
    var $nextAnswerRow  = $(':focus').closest('.row').nextAll('.row').find('.answer-row').find('input:first:enabled')
    var $nextRow        = $(':focus').closest('.row').nextAll('.row').find('input:first:enabled')

    var $next
    if      ($nextAnswer.length)     $next = $nextAnswer
    else if ($nextAnswerRow.length)  $next = $nextAnswerRow
    else                             $next = $nextRow

    $next.first().focus()
  }


  ui.focusPreviousPopupControl = function () {
    var $prevAnswer     = $(':focus').closest('.answer-row').prev('.answer-row').find('input:first:enabled')
    var $prevAnswerRow  = $(':focus').closest('.row').prevAll('.row').find('.answer-row').last().find('input:first:enabled')
    var $prevRow        = $(':focus').closest('.row').prevAll('.row').find('input:first:enabled, select:first:enabled').first()

    var $prev
    if      ($prevAnswer.length)     $prev = $prevAnswer
    else if ($prevAnswerRow.length)  $prev = $prevAnswerRow
    else                             $prev = $prevRow

    $prev.first().focus()
  }


  ui.closeAllPopups = function () {
    $('.survey .question').removeClass('popup-opened')
    $('.survey .popup:visible').fadeOut(100)
    $('.keyboard-help:visible').fadeOut(100)
    $('.survey').removeClass('popup-active')
    $('#ui-datepicker-div').fadeOut(100)
    $('.ui-autocomplete').fadeOut(100)
    $('.popup_block_layer').fadeOut().remove();
  }

  ui.openPopup = function (question) {
	ui.flushRemovals()
	var $question = ui.findElement(question)
	var $popup = $question.find('.popup')
    var visible = $popup.is(':visible')

    $question.addClass('popup-opened')
    $popup.css({'z-index':'200'});

	if (!visible) {
      $('.survey').addClass('popup-active')
        setTimeout(function () {
        $popup.fadeIn(100, function () {
          $popup.find('.type').focus()
        })
      }, 1)
    }

	var pageHeight = $(document).height();
	var pageWidth = $(window).width();

	var block_page = $('<div class="popup_block_layer"></div>');

	$(block_page).appendTo('body');

	$('.popup_block_layer').css({
		'position':'absolute',
		'top':'0',
		'left':'0',
		'background-color':'rgba(0,0,0,0.6)',
		'height':pageHeight+300,
		'width':pageWidth,
		'z-index':'100'
	});

  }

  ui.toggleKeyboardHelp = function (question) {
    var visible = $('.keyboard-help').is(':visible')
    /*ui.closeAllPopups()*/
    if (!visible) setTimeout(function () { $('.keyboard-help').fadeIn(100) }, 1)
  }


  ui.togglePopup = function (question) {
    ui.flushRemovals()

    var $question = ui.findElement(question)
    var $popup = $question.find('.popup')
    var visible = $popup.is(':visible')

    ui.closeAllPopups()

    $question.addClass('popup-opened')
    if (!visible) {
      $('.survey').addClass('popup-active')
        setTimeout(function () {
        $popup.fadeIn(100, function () {
          $popup.find('.type').focus()
        })
      }, 1)
    }
  }


  ui.focusValues = function (question) {
    var $values = ui.findElement(question).find('.values')
    if ($values.hasClass('disabled')) ui.focusCommentsLabel(question)
    else                              $values.focus()
  }


  ui.focusCommentsLabel = function (question) {
    ui.findElement(question).find('.commentsLabel').focus()
  }


  ui.closePopup = function (question) {
    var $question = ui.findElement(question)
    $question.find('.popup').fadeOut(100)
    $('.survey').removeClass('popup-active')
    $('.popup_block_layer').fadeOut().remove();
    $question.removeClass('popup-opened')
    $question.find('.text').focus()
  }

  ui.saveAndClosePopup = function (question) {
    question.flushChanges(question).done(function(arg){
    	if((dataError && dataError.isError)==undefined){
		  ui.render(arg)
		  ui.closePopup(arg);
	    }
    });

  }

  ui.moveFocusDown = function (question) {
    ui.flushRemovals()
    ui.closeAllPopups()

    var $next = ui.findElement(question).next('.survey .question')
    if ($next.length) $next.find('.text').focus()
    else              question.addNext()
  }


  ui.moveFocusUp = function (question) {
    ui.flushRemovals()
    ui.closeAllPopups()

    var $prev = ui.findElement(question).prev('.survey .question')
    $prev.find('.text').focus()
  }


  ui.indentQuestion = function (question) {
    ui.flushRemovals()
    var prev = question.previous()
    if (prev) {
      ui.hideQuestionAndChildren(question, function () {
        question.indent()
      })
    }
  }


  ui.outdentQuestion = function (question) {
    ui.flushRemovals()
    var parent = question.parent()
    if (parent) {
      ui.hideQuestionAndChildren(question, function () {
        question.outdent()
      })
    }
  }


  ui.moveQuestionUp = function (question) {
    ui.flushRemovals()
    var prev = question.previous()
    if (prev) {
      ui.hideQuestionAndChildren(question, function () {
        question.moveBefore(prev)
      })
    }
  }


  ui.moveQuestionDown = function (question) {
    ui.flushRemovals()
    var next = question.next()
    if (next) {
      ui.hideQuestionAndChildren(question, function () {
        question.moveAfter(next)
      })
    }
  }


  ui.hideQuestionAndChildren = function (question, callback) {
    var $question = ui.findElement(question)

    // find the question that immediately follows the child questions
    var $next
    var q = question
    while (!q.next() && q.parent()) {q = q.parent()}
    if (q.next()) $next = ui.findElement(q.next())

    var $questionAndChildren = $question.nextUntil($next).add($question)
    $questionAndChildren.animate({opacity: 0}, function () { $(this).slideUp() })
    $questionAndChildren.promise().done(callback)
    return $questionAndChildren
  }


  ui.onMoved = function (movedQuestion) {
    console.log('onMoved: ' + movedQuestion)

    // Note: The reversal prevents the child question blocks from switching places
    var questions = $('.survey .question').map(function () { return ui.findQuestion(this) }).get().reverse()
    ui.rerenderAll(questions)

    var $question = ui.findElement(movedQuestion)
    $question.find('> .row .text').focus()

    // find the question that immediately follows the child questions
    var q = movedQuestion
    while (!q.next() && q.parent()) {q = q.parent()}

    var $next
    if (q.next()) $next = ui.findElement(q.next())

    var $questionAndChildren = $question.nextUntil($next).add($question)
    $questionAndChildren.css({opacity: 0}).hide()
    $questionAndChildren.slideDown(function () { $(this).animate({opacity: 1}, function () { $(this).css({opacity: ''}) }) })
    $question.find('> .row .controls').pulse()
  }


  ui.loadQuestion = function (question) {
    ui.createQuestion(question)
    ui.createAnswers(question)

    ui.updateMaxScore(question)
    ui.enableAnswerControls(question)
    ui.enableDisableGoalElements(question)

    ui.renumber()
    ui.respace(false)
  }

  ui.generateAnswers = function (question) {
    console.log(question);
    ui.flushRemovals()
    ui.removeAllAnswers(question);
    ui.setReloadMessage(true);
    var questionBrand = question.props['goalBrand'] || null;
    var brandLevel =  ui.findElement(question).find('.answerLevel').val();
    var goalCountValue = ui.findElement(question).find('.isGoal').prop('checked');
    if(goalCountValue){
    	goalCountValue = 1;
    }else{
    	goalCountValue = 0;
    }


    Visualforce.remoting.Manager.invokeAction(
    _CONTROLLER_GETALL_ANSWER_BRAND_ACTION,
    questionBrand, brandLevel, goalCountValue,
        function(result, event){
            if (event.status) {

                if(result.length == 0){
                    ui.findElement(question).find('.ok').css("visibility","hidden");
                }else{
                    ui.findElement(question).find('.ok').css("visibility","visible");
                }
            	ui.findElement(question).find('.answeralert').html(result.length + ' answers generated.');
	            for(var i = 0; i<result.length;i++){
                    question.addAnswer(result[i]);
			    }
            } else  {
              console.log(event.message);
            }
        },
        {escape: false}
    );
  }


  // Re-render all questions
  ui.rerenderAll = function (allQuestions) {
    var scrollTop = $(window).scrollTop()

    ui.closeAllPopups()
    $('.survey .question').each(function () { $(this).remove() })

    var failures = 0
    while (allQuestions.length) {
      var question = allQuestions.shift()
      var canRender = true

      // Make sure the parent/previous question is already rendered
      var prev   = question.previous()
      var parent = question.parent()

      if (prev   && !ui.findElement(prev))   canRender = false
      if (parent && !ui.findElement(parent)) canRender = false

      if (canRender) {
        ui.createQuestion(question)
        failures = 0
      } else {
        failures += 1
        allQuestions.push(question) // try again later
      }

      // If it has failed on every item remaining in the list, we are stuck
      if (failures > allQuestions.length) throw new Error('infinite loop')
    }

    ui.renumber()
    ui.respace(false)

    $(window).scrollTop(scrollTop)
  }


  // ----------- Capture events and fire off ui/data methods -----------


  // Send question events to the UI
  app.Question.on('loaded',  ui.loadQuestion)
  app.Question.on('added',   ui.addQuestion)
  app.Question.on('removed', ui.onRemove)
  app.Question.on('changed', ui.render)
  app.Question.on('moved',   ui.onMoved)

  app.Answer.on('answerAdded',   ui.addAnswer)
  app.Answer.on('answerRemoved', ui.removeAnswer)


  // Send UI events to the question
  onQuestionClick('.add',        'addNext')
  onQuestionClick('.add-if',     'addChild')
  onQuestionClick('.remove',      ui.removeQuestion)
  onQuestionClick('.answers',     ui.openPopup)
  onQuestionClick('.generateAnswer', ui.generateAnswers)
  onQuestionClick('.ok',          ui.saveAndClosePopup)
  onQuestionClick('.cancel',      ui.closePopup)
  onQuestionClick('.move-up',     ui.moveQuestionUp)
  onQuestionClick('.move-down',   ui.moveQuestionDown)
  onQuestionClick('.move-left',   ui.outdentQuestion)
  onQuestionClick('.move-right',  ui.indentQuestion)

  onAnswerClick('.answer-remove', ui.removeAnswerButtonClicked)
  onAnswerClick('.answer-brand-remove', ui.removeAnswerValueButtonClicked)
  onAnswerClick('.answer-add',    'addAfter')

  bindControl('keyup',  '.text', 'text')
  bindControl('keyup',  '.conditional .answer', 'conditionalAnswer')

  bindAnswerControl('keyup',  '.popup .value', 'value')
  bindAnswerControl('keyup',  '.popup .score', 'score')
  bindControl('keyup',  '.popup .commentsLabel', 'commentsLabel')
  bindControlCheckbox('change',  '.popup .includeNone', 'includeNone')
  bindControlCheckbox('change',  '.popup .includePhotos', 'includePhotos')
  bindControlCheckbox('change',  '.popup .requirePhotos', 'requirePhotos')
  bindControl('change', '.popup .type', 'type')

  bindAnswerControl('keyup', '.popup .goalScore', 'goalScore')
  bindControl('keyup', '.popup .goalName', 'goalName')
  bindControl('change', '.popup .goalType', 'goalType')
  bindControl('change', '.popup .goalBrand', 'goalBrand')
  //bindControl('change', '.popup .goalStartDate', 'goalStartDate')
  //bindControl('change', '.popup .goalEndDate', 'goalEndDate')
  bindControlCheckbox('change',  '.popup .isGoal', 'isGoal')

  // Set up keyboard shortcuts
  bindKey('ENTER',            '.popup input, .popup select', ui.focusNextPopupControl)
  bindKey('SHIFT+ENTER',      '.popup input, .popup select', ui.focusPreviousPopupControl)
  //bindKey('ENTER',            '.commentsLabel',  ui.closePopup)
  bindKey('TAB',              '.text',    ui.togglePopup)
  bindKey('ENTER',            '.text',    ui.moveFocusDown)
  bindKey('SHIFT+ENTER',      '.text',    ui.moveFocusUp)
  bindKey('DOWN',             '.text',    ui.moveFocusDown)
  bindKey('UP',               '.text',    ui.moveFocusUp)
  bindKey('CTRL+ENTER',       '.text',    'addNext')
  bindKey('CTRL+SHIFT+ENTER', '.text',    'addChild')
  bindKey('CTRL+RIGHT',       '.text',    'indent')
  bindKey('CTRL+LEFT',        '.text',    'outdent')


  // Try to prevent leaving the page while data is still being saved/removed
  window.onbeforeunload = function() {
    if (ui._saving || ui._removals.length) return 'Hold on. Still saving...'
  }

  // Close all popups when clicking on the page
  $('html').on('click', function (e) {
    var $target = $(e.target)
    if ($target.closest('.popup, .answers').length) return
    if ($("#ui-datepicker-div").css("display")=="block") return

    /*ui.closeAllPopups()*/
  })

  // Bind events on misc UI elements
  $('.keyboard-help-icon').on('click', ui.toggleKeyboardHelp)
  $('.flash .undo').on('click', ui.undoRemovals)
  $('.createQuestion').on('click', ui.addFirstQuestion)


  // Track focus and mouse hover for each question
  $('.survey').on('mouseenter', '.question',  function (e) { user(e, 'hover',        true ) })
  $('.survey').on('mouseleave', '.question',  function (e) { user(e, 'hover',        false) })
  $('.survey').on('focus',      '.text',      function (e) { user(e, 'focus-text',   true ) })
  $('.survey').on('blur',       '.text',      function (e) { user(e, 'focus-text',   false) })
  $('.survey').on('focus',      '.value',     function (e) { user(e, 'focus-values', true ) })
  $('.survey').on('blur',       '.value',     function (e) { user(e, 'focus-values', false) })
  $('.survey').on('focus',      '.score',     function (e) { user(e, 'focus-scores', true ) })
  $('.survey').on('blur',       '.score',     function (e) { user(e, 'focus-scores', false) })


  // Bind an input/select to set a value on the question
  function bindControl (event, selector, property) {
    $('.survey').on(event, selector, function (e) {
      ui.flushRemovals()

      var changes = {}
      changes[property] = $(this).val()
	  var question = ui.findQuestion(this)

	  var nameElement = ui.findElement(question).find('.goalName');
	  var nameValue;

	  if(property==='goalType' || property==='goalBrand'){
	  	var typeValue = ui.findElement(question).find('.goalType').val();
	  	var brandValue = ui.findElement(question).find('.goalBrand').val();

	  	if(brandValue && brandValue.length>4){
	  		brandValue = brandValue.substring(4,brandValue.length);
	  	}

	  	nameValue = typeValue +' - ' +  brandValue;
	  }

	  /* Change the answerbrandlevel options based on selected brand level.*/
	  if(property==='goalBrand'){

	  	var goalBrandName = ui.findElement(question).find('.goalBrand').val();

		if(goalBrandName!=''){
			var brandLevel = goalBrandName.substring(1,2);
			var brandLevelSelect = ui.findElement(question).find('.answerLevel');
			brandLevelSelect.html('<option value="-SELECT-">-SELECT-</option>');
			if(brandLevel < 2) brandLevelSelect.append("<option value='L2'>L2</option>");
			if(brandLevel < 3) brandLevelSelect.append("<option value='L3'>L3</option>");
			if(brandLevel < 4) brandLevelSelect.append("<option value='L4'>L4</option>");
			if(brandLevel < 5) brandLevelSelect.append("<option value='L5'>L5</option>");
			if(brandLevel < 6) brandLevelSelect.append("<option value='L6'>L6</option>");
		}
	  }
	  nameElement.val(nameValue || nameElement.val());
	  changes['goalName'] = nameElement.val();

      question.set(changes)
      ui.render(question)
    })
  }

  // Bind an input/select to set a property on the question
  function bindAnswerControl (event, selector, property) {
    $('.survey').on(event, selector, function (e) {
      ui.flushRemovals()

      var changes = {}
      var valuetoSave = $(this).val();
      if(property=='value' && valuetoSave.substring(0,1)=='L' && valuetoSave.indexOf(':')==2){
          valuetoSave = valuetoSave.substring(4,valuetoSave.length);
      }
      changes[property] = valuetoSave;

      var answer = ui.findAnswer(this)
      answer.set(changes)
      ui.render(answer.question)
    })
  }

  function bindControlCheckbox (event, selector, property) {
    $('.survey').on(event, selector, function (e) {
      ui.flushRemovals()

      var changes = {}
      changes[property] = $(this).prop('checked')

      var question = ui.findQuestion(this)
      question.set(changes)
      ui.render(question)
    })
  }

  // Track when shift/ctrl keys are held down
  var held = {}
  $('body').on('keydown', function (e) {
    if      (e.keyCode === 16) held.shift = true
    else if (e.keyCode === 17)  held.ctrl  = true
  })
  $('body').on('keyup',   function (e) {
    if      (e.keyCode === 16) held.shift = false
    else if (e.keyCode === 17)  held.ctrl  = false
  })


  // Bind a keypress to an event handler (or method on the question)
  function bindKey (keyPressed, selector, action) {
    var KEY_CODES = {
      TAB:   9,
      ENTER: 13,
      LEFT:  37,
      UP:    38,
      RIGHT: 39,
      DOWN:  40,
    }

    // Convert to keycode and modifiers 'SHIFT+ENTER' -> {code: 13, shift: true}
    var key = {}
    $.each(keyPressed.split('+'), function (i, k) {
      if      (k === 'SHIFT') return key.shift = true
      else if (k === 'CTRL')  return key.ctrl  = true
      else if (KEY_CODES[k])  return key.code  = KEY_CODES[k]
      else    console.error('Unknown key: ' + k)
    })

    $('.survey').on('keydown', selector, function (e) {

      if (e.keyCode === key.code && (!!held.shift == !!key.shift) && (!!held.ctrl == !!key.ctrl)) {
        e.preventDefault()

        var question = ui.findQuestion(e.target)

        if (typeof action === 'function') return action(question)

        if (typeof action === 'string') {
          // If the action is a string, assume it is a method on the question
          if (typeof question[action] !== 'function') return console.error('The "' + action + '" method is not availble on the question.')
          question[action]()
        }
      }

    })
  }


  // Bind a click on the question to an method on the ui (or on the question)
  function onQuestionClick (selector, action) {
    $('.survey').on('click', selector, function (e) {
      e.preventDefault()

      var question = ui.findQuestion(e.target)

      if (typeof action === 'function') return action(question)

      if (question[action]) question[action]()
      else                  console.log('No action named: ' + action)
    })
  }


  // Bind a click on the answer to an method on the ui (or on the answer)
  function onAnswerClick (selector, action) {
    $('.survey').on('click', selector, function (e) {
      e.preventDefault()

      var answer = ui.findAnswer(e.target)

      if (typeof action === 'function') return action(answer)

      if (answer[action]) answer[action]()
      else                console.log('No action named: ' + action)
    })
  }


  // Set a data attribute based on user input (e.g. mouse hover)
  function user (e, type, state) {
    var $question = $(e.target).closest('.question')
    $question.data(type, state)
    toggleButtons($question)
  }


  // Show/hide the add/remove buttons on a question
  function toggleButtons ($question) {
    if ($question.data('hover') || $question.data('focus-text') || $question.data('focus-values') || $question.data('focus-scores')) {
      $question.find('.buttons').css({opacity:1})
    } else {
      $question.find('.buttons').css({opacity:0.1})
    }
  }


})(this)
