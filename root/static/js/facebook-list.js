/*
  Moogets - TextboxList + Autocomplete 0.2
  - MooTools version required: 1.2
  - MooTools components required: Element.Event, Element.Style, Selectors, Request.JSON and dependencies.
  
  Credits:
  - Idea: Facebook
  
  Changelog:
  - 0.1: initial release
  - 0.2: added click support, removed $attributes use, code cleanup
*/

/* Copyright: Guillermo Rauch <http://devthought.com/> - Distributed under MIT - Keep this message! */

var FacebookList = new Class({
  
  Extends: TextboxList,
  
  options: {    
    onBoxDispose: function(item) { this.autoFeed(item.retrieve('text')); },
    onInputFocus: function() { this.autoShow(); },    
    onInputBlur: function(el) { 
      this.lastinput = el;
      this.blurhide = this.autoHide.delay(200, this);
    },
    autocomplete: {
      'opacity': 0.8,
      'maxresults': 10,
      'minchars': 1
    }
  },
  
  initialize: function(element, autoholder, options) {
    this.parent(element, options);
    this.data = [];
		this.autoholder = $(autoholder).set('opacity', this.options.autocomplete.opacity);
		this.autoresults = this.autoholder.getElement('ul');
		var children = this.autoresults.getElements('li');
    children.each(function(el) { this.add(el.innerHTML); }, this); 
  },
  
  autoShow: function(search) {
    this.autoholder.setStyle('display', 'block');
    this.autoholder.getChildren().setStyle('display', 'none');
    if(! search || ! search.trim() || (! search.length || search.length < this.options.autocomplete.minchars)) 
    {
      this.autoholder.getElement('.default').setStyle('display', 'block');
      this.resultsshown = false;
    } else {
      this.resultsshown = true;
      this.autoresults.setStyle('display', 'block').empty();
      this.data.filter(function(str) { return str ? str.test(search, 'i') : false; }).each(function(result, ti) {
        if(ti >= this.options.autocomplete.maxresults) return;
        var that = this;
        var el = new Element('li').addEvents({
          'mouseenter': function() { that.autoFocus(this); },
          'click': function(e) { 
            new Event(e).stop();
            that.autoAdd(this); 
          }
        }).set('html', this.autoHighlight(result, search)).inject(this.autoresults);
        el.store('result', result);
        if(ti == 0) this.autoFocus(el);
      }, this);
    }
    return this;
  },
  
  autoHighlight: function(html, highlight) {
    return html.replace(new RegExp(highlight, 'gi'), function(match) {
      return '<em>' + match + '</em>';
    });
  },
  
  autoHide: function() {    
    this.resultsshown = false;
    this.autoholder.setStyle('display', 'none');    
    return this;
  },
  
  autoFocus: function(el) {
    if(! el) return;
    if(this.autocurrent) this.autocurrent.removeClass('auto-focus');
    this.autocurrent = el.addClass('auto-focus');
    return this;
  },
  
  autoMove: function(direction) {    
    if(!this.resultsshown) return;
    this.autoFocus(this.autocurrent['get' + (direction == 'up' ? 'Previous' : 'Next')]());
    return this;
  },
  
  autoFeed: function(text) {
    this.data.include(text);    
    return this;
  },
  
  autoAdd: function(el) {
    if(!el || ! el.retrieve('result')) return;
    this.add(el.retrieve('result'));
    delete this.data[this.data.indexOf(el.retrieve('result'))];
    this.autoHide();
    var input = this.lastinput || this.current.retrieve('input');
    input.set('value', '').focus();
    return this;
  },
  
  createInput: function(options) {
    var li = this.parent(options);
    var input = li.retrieve('input');
    input.addEvents({
      'keydown': function(e) {
        this.dosearch = false;
        switch(new Event(e).code) {
          case Event.Keys.up: return this.autoMove('up');
          case Event.Keys.down: return this.autoMove('down');        
          case Event.Keys.enter: 
            if(! this.autocurrent) break;
            this.autoAdd(this.autocurrent);
            this.autocurrent = false;
            this.autoenter = true;
            break;
          case Event.Keys.esc: 
            this.autoHide();
            if(this.current && this.current.retrieve('input'))
              this.current.retrieve('input').set('value', '');
            break;
          default: this.dosearch = true;
        }
      }.bind(this),
      'keyup': function() {
        if(this.dosearch) this.autoShow(input.value);
      }.bind(this)
    });
    input.addEvent(Browser.Engine.trident ? 'keydown' : 'keypress', function(e) { 
      if(this.autoenter) new Event(e).stop()
      this.autoenter = false;
    }.bind(this));
    return li;
  },
  
  createBox: function(text, options) {
    var li = this.parent(text, options);
    return li.addEvents({
      'mouseenter': function() { this.addClass('bit-hover') },
      'mouseleave': function() { this.removeClass('bit-hover') }
    }).adopt(new Element('a', {
      'href': '#',
      'class': 'closebutton',
      'events': {
        'click': function(e) {
          new Event(e).stop();
          if(! this.current) this.focus(this.maininput);
          this.dispose(li);
        }.bind(this)
      }
    })).store('text', text);
  }
  
});
