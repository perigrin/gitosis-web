var PageWidget = new Class({
	Implements: [Options, Events],
    options: {
        'id':      '',
        className: 'PageWidget',
        args:      {},
    },
    initialize: function (element, options) {
		this.setOptions(options);
		this.element = $(element);
        if ($type(this['postInitialize']) == 'function')
            this.postInitialize();
        return;
    }
});

var Page_Project_Create = new Class({
    Extends: PageWidget,
	Implements: [Options, Events],
    postInitialize: function() {
        // init
        var tlist2 = new FacebookList('members', 'members_list');

        // fetch and feed
        /*
        new Request.JSON({'url': 'json.html', 'onComplete': function(j) {
        j.each(tlist2.autoFeed, tlist2);
        }}).send();
        */
        return;
    }
});
