({
	animate : function(cmp) {
        
         
		var value = 0;
        var numValue = 0;
        var startDrawGrades = -90;
        var toGrade = startDrawGrades;
        var percentage = cmp.get('v.percentage');
        
        var grades     = ((360*percentage)/100);
        var max = (grades+startDrawGrades);
        var scale = grades/120;
        var accVal = .4;
        var accValDesc = 2;
        var accValDesc2 = .05;
        var acc = 0;
        
        function draw() {
            
          //var canvas = document.getElementById('canvas');
          
          var canvas = cmp.find('canvas').getElement();
            
          if (canvas.getContext && toGrade < max){  
              
            var ctx = canvas.getContext('2d');
            ctx.clearRect(0, 0, 85, 85);
            ctx.save();
            ctx.beginPath();
            ctx.arc(43,43,37,0,Math.PI*2,true); 
            ctx.lineWidth= 10; 
            ctx.strokeStyle = '#d8dde5';
            ctx.stroke();
            
            ctx.restore();
            ctx.restore();
              
            ctx.save();
            ctx.font = "22px Lato";
            
            ctx.fillText(Math.floor((value*100)/360)+'%', 22, 50);
            
            ctx.restore();
            ctx.save();
            ctx.beginPath();
            ctx.arc(43,43,37,(Math.PI/180)*(-90),(Math.PI/180)*(toGrade),false); 
            ctx.lineWidth= 10; 
            ctx.strokeStyle = '#78d348';
            ctx.stroke();
            ctx.restore();
            console.log('toGrade', toGrade);
            console.log('70', max / 1.3);
            var increment = scale;
            if(acc >= 0){
             if(toGrade < max / 1.5){
               increment = scale + acc;
              }else if(toGrade < max / 1.3){
                acc -= accValDesc;
                increment=scale + acc;
              }else {
                acc -= accValDesc + accValDesc2;
                increment = scale + acc;
              }
            }
            toGrade += increment;
            value += Math.abs(increment);
            console.log(toGrade, value);
            acc += accVal;
          }
        window.requestAnimationFrame(draw);
       }
       setTimeout(draw, 1000); 
	}
})