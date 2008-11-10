/*
  Moogets - TextboxList 0.2
  - MooTools version required: 1.2
  - MooTools components required: Element.Event, Element.Style and dependencies.
  
  Credits:
  - Idea: Facebook + Apple Mail
  - Caret position method: Diego Perini <http://javascript.nwbox.com/cursor_position/cursor.js>
  
  Changelog:
  - 0.1: initial release
  - 0.2: code cleanup, small blur/focus fixes
*/

/* Copyright: Guillermo Rauch <http://devthought.com/> - Distributed under MIT - Keep this message! */

Element.implement({
  
  getCaretPosition: function() {
    if (this.createTextRange) {
      var r = document.selection.createRange().duplicate();
    	r.moveEnd('character', this.value.length);
    	if (r.text === '') return this.value.length;
    	return this.value.lastIndexOf(r.text);
    } else return this.selectionStart;
  }
  
});

var ResizableTextbox = new Class({
  
  Implements: Options,
  
  options: {
    min: 5,
    max: 500,
    step: 7
  },
  
  initialize: function(element, options) {
    var that = this;
    this.setOptions(options);
    this.el = $(element);
    this.width = this.el.offsetWidth;
    this.el.addEvents({
      'keydown': function() {
        this.store('rt-value', this.get('value').length);
      },
      'keyup': function() {
        var newsize = that.options.step * this.get('value').length;
        if(newsize <= that.options.min) newsize = that.width;
        if(! (this.get('value').length == this.retrieve('rt-value') || newsize <= that.options.min || newsize >= that.options.max))
          this.setStyle('width', newsize);
      }
    });
  }
  
});

var TextboxList = new Class({
  
  Implements: [Events, Options],

  options: {/*
    onFocus: $empty,
    onBlur: $empty,
    onInputFocus: $empty,
    onInputBlur: $empty,
    onBoxFocus: $empty,
    onBoxBlur: $empty,
    onBoxDispose: $empty,*/
    resizable: {},
    className: 'bit',
    separator: '###',
    extrainputs: true,
    startinput: true,
    hideempty: true
  },
  
  initialize: function(element, options) {
    this.setOptions(options);
    this.element = $(element).setStyle('display', 'none');    
    this.bits = new Hash;
    this.events = new Hash;
    this.count = 0;
    this.current = false;
    this.maininput = this.createInput({'class': 'maininput'});
    this.holder = new Element('ul', {
      'class': 'holder', 
      'events': {
        'click': function(e) { 
          e = new Event(e).stop();
          if(this.maininput != this.current) this.focus(this.maininput); 
        }.bind(this)
      }
    }).inject(this.element, 'before').adopt(this.maininput);
    this.makeResizable(this.maininput);
    this.setEvents();
  },
  
  setEvents: function() {
    document.addEvent(Browser.Engine.trident ? 'keydown' : 'keypress', function(e) {    
      if(! this.current) return;
      if(this.current.retrieve('type') == 'box' && e.code == Event.Keys.backspace) new Event(e).stop();
    }.bind(this));      
         
    document.addEvents({
      'keyup': function(e) { 
        e = new Event(e).stop();
        if(! this.current) return;
        switch(e.code){
          case Event.Keys.left: return this.move('left');
          case Event.Keys.right: return this.move('right');
          case Event.Keys.backspace: return this.moveDispose();
        }
      }.bind(this),
      'click': function() { this.fireEvent('onBlur').blur(); }.bind(this)
    });
  },
  
  update: function() {
    this.element.set('value', this.bits.getValues().join(this.options.separator));
    return this;
  },
  
  add: function(text, html) {
    var id = this.options.className + '-' + this.count++;
    var el = this.createBox($pick(html, text), {'id': id}).inject(this.current || this.maininput, 'before');
    el.addEvent('click', function(e) {
      e = new Event(e).stop();
      this.focus(el);
    }.bind(this));
    this.bits.set(id, text);    
    if(this.options.extrainputs && (this.options.startinput || el.getPrevious())) this.addSmallInput(el, 'before');
    return el;
  },
  
  addSmallInput: function(el, where) {
    var input = this.createInput({'class': 'smallinput'}).inject(el, where);
    input.store('small', true);
    this.makeResizable(input);
    if(this.options.hideempty) input.setStyle('display', 'none');
    return input;
  },
  
  dispose: function(el) {
    this.bits.remove(el.id);
    if(el.getPrevious().retrieve('small')) el.getPrevious().destroy();
    if(this.current == el) this.focus(el.getNext());
    if(el.retrieve('type') == 'box') this.fireEvent('onBoxDispose', el);
    el.destroy();    
    return this;
  },
  
  focus: function(el, nofocus) {
    if(! this.current) this.fireEvent('onFocus', el);
    else if(this.current == el) return this;
    this.blur();
    el.addClass(this.options.className + '-' + el.retrieve('type') + '-focus');
    if(el.retrieve('small')) el.setStyle('display', 'block');
    if(el.retrieve('type') == 'input') {
      this.fireEvent('onInputFocus', el);      
      if(! nofocus) this.callEvent(el.retrieve('input'), 'focus');
    }
    else this.fireEvent('onBoxFocus', el);
    this.current = el;    
    return this;
  },
  
  blur: function(noblur) {
    if(! this.current) return this;
    if(this.current.retrieve('type') == 'input') {
      var input = this.current.retrieve('input');
      if(! noblur) this.callEvent(input, 'blur');   
      this.fireEvent('onInputBlur', input);
    }
    else this.fireEvent('onBoxBlur', this.current);
    if(this.current.retrieve('small') && ! input.get('value') && this.options.hideempty) 
      this.current.setStyle('display', 'none');
    this.current.removeClass(this.options.className + '-' + this.current.retrieve('type') + '-focus');
    this.current = false;
    return this;
  },
  
  createBox: function(text, options) {
    return new Element('li', $extend(options, {'class': this.options.className + '-box'})).set('html', text).store('type', 'box');
  },
  
  createInput: function(options) {
    var li = new Element('li', {'class': this.options.className + '-input'});
    var el = new Element('input', $extend(options, {
      'type': 'text', 
      'events': {
        'click': function(e) { e = new Event(e).stop(); },
        'focus': function(e) { if(! this.isSelfEvent('focus')) this.focus(li, true); }.bind(this),
        'blur': function() { if(! this.isSelfEvent('blur')) this.blur(true); }.bind(this),
        'keydown': function(e) { this.store('lastvalue', this.value).store('lastcaret', this.getCaretPosition()); }
      }
    }));
    return li.store('type', 'input').store('input', el).adopt(el);
  },
  
  callEvent: function(el, type) {
    this.events.set(type, el);
    el[type]();
  },
  
  isSelfEvent: function(type) {
    return (this.events.get(type)) ? !! this.events.remove(type) : false;
  },
  
  makeResizable: function(li) {
    var el = li.retrieve('input');
    el.store('resizable', new ResizableTextbox(el, $extend(this.options.resizable, {min: el.offsetWidth, max: this.element.getStyle('width').toInt()})));
    return this;
  },
  
  checkInput: function() {
    var input = this.current.retrieve('input');
    return (! input.retrieve('lastvalue') || (input.getCaretPosition() === 0 && input.retrieve('lastcaret') === 0));
  },
  
  move: function(direction) {
    var el = this.current['get' + (direction == 'left' ? 'Previous' : 'Next')]();
    if(el && (! this.current.retrieve('input') || ((this.checkInput() || direction == 'right')))) this.focus(el);
    return this;
  },
  
  moveDispose: function() {
    if(this.current.retrieve('type') == 'box') return this.dispose(this.current);
    if(this.checkInput() && this.bits.getKeys().length && this.current.getPrevious()) return this.focus(this.current.getPrevious());
  }
  
});