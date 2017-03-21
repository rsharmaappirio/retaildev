body { font-family: arial; }

#templates                                  { display: none }

.loading                                    { font-weight: bold; font-size: 2em; color: #ccc; margin: 1em;}
.saving                                     { color: #666; font-size: 0.9em; display:none; z-index: 500; padding: 8px; background: #ff9; border: 1px solid #ccc; position: fixed; top: 0; right: 0; }
.survey                                     { min-width: 1000px; margin-left:20px; font-family: arial; font-size: 14px}
.createQuestion                             { display: none; color: #00f; }

.flash                                      { display: none; position:fixed; background-color:rgba(175,0,0,0.8); color: #fff; margin: auto; text-align: center; z-index: 100; padding: 0 8px; width: 400px; top: 0; left: 0; right: 0; border: 1px solid #900; border-top: 0;}
.flash a                                    { display: inline-block; padding: 8px; color: #fff;}

.questions                                  { margin-bottom: 200px; }
.row                                        { white-space: nowrap; }
.centered                                   { text-align: center; }

.keyboard-help-icon                         { opacity: 0.7; position: absolute; top: 1em; right: 1em; }
.keyboard-help-icon img                     { border: 0; }
.keyboard-help-icon:hover                   { opacity: 1; }
.keyboard-help                              { position: absolute; top: 4em; right: 1em; color: #333; background: #eee; border: 1px solid #999; padding: 1em; display:none; }
.keyboard-help h4                           { text-align: center; text-decoration: underline; margin:8px; }
.keyboard-help dt                           { float:left; width: 9em; text-align: right; clear:both;}
.keyboard-help dd                           { float:left; margin-left: 1em; }

.button                                     { display:inline-block; padding: 8px 12px; vertical-align: top; }
.number                                     { display:inline-block; color: #aaa; width: 48px; text-align: center; display:inline-block; padding-top:12px; position: relative; height: 28px; float:left;}

.number a                                   { display: none; background: #ddd; color: #aaa; border: 1px solid #ccc; position: absolute; font-size:0.8em; text-decoration: none; vertical-align: middle; z-index: 1; }
.number:hover a                             { display: block; }
.move-up                                    { height: 20px; line-height: 20px; top: -22px; right: -1px;                 left: -1px;  border-top-left-radius: 6px;    border-top-right-radius: 6px; }
.move-down                                  { height: 20px; line-height: 20px;             right: -1px;  bottom: -22px; left: -1px;  border-bottom-left-radius: 6px; border-bottom-right-radius: 6px; }
.move-left                                  { width:  20px; line-height: 40px; top: -1px;                bottom: -1px;  left: -22px; border-top-left-radius: 6px;    border-bottom-left-radius: 6px; }
.move-right                                 { width:  20px; line-height: 40px; top: -1px;  right: -22px; bottom: -1px;               border-top-right-radius: 6px;   border-bottom-right-radius: 6px; }

.can-move-up   .number .move-up             { background: #47d; color: #fff; border: 1px solid #666; }
.can-move-down .number .move-down           { background: #47d; color: #fff; border: 1px solid #666; }
.can-outdent   .number .move-left           { background: #47d; color: #fff; border: 1px solid #666; }
.can-indent    .number .move-right          { background: #47d; color: #fff; border: 1px solid #666; }

.can-move-up   .number .move-up:hover       { background: #69f; }
.can-move-down .number .move-down:hover     { background: #69f; }
.can-outdent   .number .move-left:hover     { background: #69f; }
.can-indent    .number .move-right:hover    { background: #69f; }

.controls                                   { position: relative;}
.controls, .buttons                         { display:inline-block; background: #eee; border: 1px solid #ccc; vertical-align: top; }
.text-controls                              { width: 720px;  border-left: 1px solid #ccc; display: inline-block; padding-left: 4px; height:40px; overflow:hidden;}
.deleted .controls                          { background-color: #d55 !important; }

.popup                                      { position: absolute; top: 32px; right: 8px; border: 1px solid #999; padding: 8px; background-color: #eee; width: 450px; display: none; z-index: 10;font-family: arial; font-size: 12px;}
.popup label                                { display: block; color: #999; margin-top:0.3em; font-size: 0.9em; }
.popup select, .popup input, .popup .ok     { font-size: 1em; width: 100%;}
.popup input                                { width: 95%; padding: 2px 4px; font-size: 0.9em;}
.popup .row                                 { margin-bottom: 5px;float: left; width: 100%; }
.popup .ok                                  { height: 25px !important; width: 77px !important; margin-left: 250px !important; padding: 4px !important;background: none !important; background-color: #35f !important; color: #fff !important; border: 1px solid #333 !important;border-radius: 6px !important;}
.popup .cancel								{ height: 25px !important; width: 77px !important; margin-left: 20px !important; padding: 4px !important;background: none !important; background-color: #35f !important; color: #fff !important; border: 1px solid #333 !important;border-radius: 6px !important;}
.popup .ok:hover                            { background-color: #57f !important; }
.popup .cancel:hover            		    { background-color: #57f !important; }
.disabled                                   { color: #ccc; }
.popup .same-row label                      { display: inline; }
.popup .same-row input                      { width:20px; }
.popup .gap                                 { margin-bottom: 10px; }
.popup .answerLevel							{ width: 40%;}

.includeNone                                { width: 12px !important; }
.includePhotos				                { width: 12px !important; }
.requirePhotos				                { width: 12px !important; }
.question                                   { margin-top: 1px;}
.spacer                                     { height: 12px; display:none; }
.text                                       { width: 500px; height: 1.2em; float:left;}
.text, .answers                             { margin: 7px 4px; font-size: 1em; padding: 4px; }
.text, .values, .conditional .answer        { font-size: 1em; }
.values                                     { white-space: normal; }
.answers                                    { font-size: 0.9em; text-align: right; float: right; color: #666; display: inline-block; width: 170px; padding: 6px; text-decoration: none; }
.answers .type                              { color: #bbb; margin-right: 4px; font-style: italic; }
.drop-down-arrow                            { font-size: 0.8em; float:right; margin: 2px;}
.conditional                                { display: none; padding: 8px 0px 2px; margin-left: -34px;}
.conditional .arrow                         { display:inline-block; margin: 0px; float:left;}
.conditional .arrow img                     { vertical-align: bottom; }
.popup-opened .answers                      { color: #07f;}

.popup-active .question                     { opacity: 0.3 }
.popup-active .question.popup-opened        { opacity: 1 }

.answer-column                              { float: left; width: 65%; }
.score-column                               { float: left;padding-left: 10px; }
.goal-score-column                          { float: left;padding-left: 10px; }
.answer-button-column                       { float: left;padding-left: 10px; }
.score-total-column                         { float: left; width: 15%; }
.score .goalScore                           { text-align: right; }


.first-conditional .conditional             { display: block; }
.depth-1                                    { margin-left:  50px; }
.depth-2                                    { margin-left: 115px; }
.depth-3                                    { margin-left: 180px; }
.depth-4                                    { margin-left: 245px; }
.depth-5                                    { margin-left: 310px; }
.depth-6                                    { margin-left: 375px; }
.depth-7                                    { margin-left: 440px; }
.depth-8                                    { margin-left: 505px; }
.depth-9                                    { margin-left: 570px; }
.depth-10                                   { margin-left: 635px; }
.after-conditional .spacer                  { display: block; }

.depth-1  .number                           { width:  50px; }
.depth-2  .number                           { width:  65px; }
.depth-3  .number                           { width:  80px; }
.depth-4  .number                           { width:  95px; }
.depth-5  .number                           { width: 110px; }
.depth-6  .number                           { width: 125px; }
.depth-7  .number                           { width: 140px; }
.depth-8  .number                           { width: 155px; }
.depth-9  .number                           { width: 170px; }
.depth-10 .number                           { width: 175px; }

.button                                     { border-left: 1px solid #ccc; float:left; height: 17px; width: 14px; }
.button:first-child                         { border-left: 0; }
.buttons                                    { padding: 0; margin-left: -1px; margin-top: 4px; opacity: 0.1; border: 0; }

.buttons .add                               { background: #0a0 url('/img/add.png')    no-repeat 8px 4px; margin-top: 0px;}
.buttons .add-if                            { background: #0a0 url('/img/add-if.png') no-repeat 8px 4px; margin-top: 0px;}
.buttons .add:hover, .buttons .add-if:hover { background-color: #0c0; }
.buttons .remove                            { background: #a00 url('/img/remove.png') no-repeat 8px 4px; border-bottom-right-radius: 6px; border-top-right-radius: 6px; margin-top: 0px;}
.buttons .remove:hover                      { background-color: #c00; }

.answer-button                              { background-color: #fff; border: 1px solid #999; float:left; height: 20px; width: 23px;}
.answer-buttons                             { float:right; margin-top: 2px; }

.answer-brand-buttons                       { float:right; margin-top: 2px; }

.answer-add                                 { background-image: url('/img/answer-add.png');    background-repeat: no-repeat; background-position: 6px; border-bottom-left-radius: 6px; border-top-left-radius: 6px;}
.answer-add:hover                           { background-color: #dfd; }
.answer-remove                              { background-image: url('/img/answer-remove.png'); background-repeat: no-repeat; background-position: 6px; border-bottom-right-radius: 6px; border-top-right-radius: 6px; border-left: 0;}
.answer-remove:hover                        { background-color: #fdd; }


.answer-row:first-child:last-child .answer-remove,
.answer-button.disabled                     { background-color: #ddd; opacity: 0.5}

.flash,
.saving,
.keyboard-help,
.popup {
  -webkit-box-shadow: 0px 6px 12px 0px rgba(0,0,0,0.3);
  -moz-box-shadow:    0px 6px 12px 0px rgba(0,0,0,0.3);
  box-shadow:         0px 6px 12px 0px rgba(0,0,0,0.3);
}


.move-down {
  -webkit-box-shadow: 0px 1px 3px 0px rgba(0,0,0,0.3);
  -moz-box-shadow:    0px 1px 3px 0px rgba(0,0,0,0.3);
  box-shadow:         0px 1px 3px 0px rgba(0,0,0,0.3);
}

.move-up {
  -webkit-box-shadow: 0px -1px 3px 0px rgba(0,0,0,0.3);
  -moz-box-shadow:    0px -1px 3px 0px rgba(0,0,0,0.3);
  box-shadow:         0px -1px 3px 0px rgba(0,0,0,0.3);
}

.move-right {
  -webkit-box-shadow: 1px 0px 3px 0px rgba(0,0,0,0.3);
  -moz-box-shadow:    1px 0px 3px 0px rgba(0,0,0,0.3);
  box-shadow:         1px 0px 3px 0px rgba(0,0,0,0.3);
}

.move-left {
  -webkit-box-shadow: -1px 0px 3px 0px rgba(0,0,0,0.3);
  -moz-box-shadow:    -1px 0px 3px 0px rgba(0,0,0,0.3);
  box-shadow:         -1px 0px 3px 0px rgba(0,0,0,0.3);
}

.type-column                              { float: left; width: 49%; }
.brand-column                             { float: left; width: 49%; padding-left: 2%;}

.level-for-answers-column                 { float: left; width: 49%; }
.level-for-answers-button-column          { float: left; width: 49%; padding-left: 2%;}

.startdate-column                         { float: left; width: 49%; }
.enddate-column                           { float: left; width: 49%; padding-left: 2%;}

.date-pick	                              {width: 95%; padding: 2px 4px; font-size: 0.9em;}
.small-column							  {float: left;width: 10%;padding-left: 15px;}
.max-score                                {float: left;padding-right: 2px;}
.max-score-label                          {padding-left: 0px;}
.max-goal-score                           {float: left;padding-right: 2px;}

hr.line-style                             {border: 0;height: 0; border-top: 1px solid rgba(0, 0, 0, 0.1);border-bottom: 1px solid rgba(255, 255, 255, 0.3);}
