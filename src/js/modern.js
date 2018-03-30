$(window).on("load", function(){     
"use strict";

$.ready.then(function(){				  
 // intro begin
 var count = 0;
 
mainpage();

// start website
function mainpage(){ 
    // variable navigation
    var Mc1  = $('#wrappermodern');
    var Mc2  = $('#wrapfooter').show();
    var Mcimg1  = $('.bgmodern img');
    var Mctoggle = $('.sidebar-nav li a');
    var Mciconmenu = $('.anim-nav');
    
    // element variable page
    var elepage = $('div, h1, h2, h3, h4, h5, p, ul, li, .modernicon, .modernbutton');
    
    // page var
    var idx = $('#home');
    var abt = $('#about');
    var resume = $('#resume');
    var skill = $('#skill');
	var holdside = $('.holdsidebar');

    // responsive
    if($(window).width() < 1025){
    idx.fadeIn(1000);
	page();
    Mc1.removeClass('toggled');
    Mc2.addClass('opacino');
    Mcimg1.css('position', 'fixed');
    
    // menu toggle
    Mctoggle.on('click', function() {
        Mctoggle.removeClass('active');
        $(this).addClass('active');
        Mciconmenu.toggleClass('open');
        Mc1.toggleClass('toggled');
        Mc2.toggleClass('opacino');
        Mc2.toggleClass('opaci');
    });
    // end responsive
    }else{	
    // desktop    
    ($(window).width() > 1025)
	idx.fadeIn(1000);
	page();
    Mc2.removeClass('opacino');
    Mcimg1.css('position', '');
    Mc1.addClass('toggled');
    // end desktop
    }
    
    // menu toggle
      Mciconmenu.on('click', function(e) {
        e.preventDefault();
        $(this).toggleClass('open');
        Mc1.toggleClass('toggled');
        Mc2.toggleClass('opacino');
        Mc2.toggleClass('opaci');
    });
    
    // menu active
    Mctoggle.on('click', function() {
        Mctoggle.removeClass('active');
        $(this).addClass('active');
    });

//slideshow home start
$(function() {
    var slideBegin = 8000,
        transSpeed = 800,
        simple_slideshow = $('#homeSlider'),
        listItems = simple_slideshow.children('.bgmodern'),
        listLen = listItems.length,
        i = 0,
        changeList = function() {
            listItems.eq(i).fadeOut(transSpeed);
            i += 1, i === listLen && (i = 0), listItems.eq(i).fadeIn(transSpeed);
        };
    listItems.not(':first').hide(), setInterval(changeList, slideBegin);
});

$(function() {
    var slideBegin = 3000,
        transSpeed = 500,
        simple_slideshow = $('#homeSlidertext'),
        listItems = simple_slideshow.children('h3'),
        listLen = listItems.length,
        i = 0,
        changeList = function() {
            listItems.eq(i).fadeOut(transSpeed, function() {
                i += 1, i === listLen && (i = 0), listItems.eq(i).fadeIn(transSpeed)
            })
        };
    listItems.not(':first').hide(), setInterval(changeList, slideBegin);
});
//slideshow home end
      
    
    // function page
    $('#home-btn').on('click', function(e) {
    e.preventDefault();
	holdside.show();
	$(".current").fadeOut(1000, function() {
                idx.fadeIn(1000);
                $(".current").removeClass("current");
                idx.addClass("current");
				page();
            });
    });
    
    $('#about-btn').on('click', function(e) {
    e.preventDefault();
	holdside.show();
	$(".current").fadeOut(1000, function() {
                abt.fadeIn(1000);
                $(".current").removeClass("current");
                abt.addClass("current");
				page();
            });
    });
    
    $('#resume-btn').on('click', function(e) {
    e.preventDefault();
	holdside.show();
	$(".current").fadeOut(1000, function() {
                resume.fadeIn(1000);
                $(".current").removeClass("current");
                resume.addClass("current");
				page();
            });
    });
    
    $('#skill-btn').on('click', function(e) {
    e.preventDefault();
	holdside.show();
	$(".current").fadeOut(1000, function() {
                skill.fadeIn(1000);
                $(".current").removeClass("current");
                skill.addClass("current");
				page();
            });
    });
    
    // function page end

// start animation
function page(){
     $([elepage]).each(function(index, foundElements) {
           foundElements.each(function(element) {
            var $this = $(this);
            var time = $(this).attr('data-time');
            setTimeout(function() {
            $this.addClass('intro');
            }, time);
        });
        setTimeout(function () {
        holdside.hide();}, 2500
        );
    });
}

}
// end website

});

   
// owlCarousel our client
var owl = $("#owl-modern");
   owl.owlCarousel({
   items : 5, 
   itemsDesktop : [1000,4], 
   itemsDesktopSmall : [900,3], 
   itemsTablet: [600,2],
   itemsMobile : false,
   autoPlay : 1500,
   stopOnHover : true
});

/*
*
plugin end
*
*/


});