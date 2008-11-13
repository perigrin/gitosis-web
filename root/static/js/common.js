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
        this.formValidator = new FormValidator($('NewProject'));

        // init
        var memberlist = new FacebookList('members', 'members_list', {separator: ' '});
        if ($type(this.options['ssh_keys']) == 'array') {
            var keys = this.options.ssh_keys;
            for (var i = 0; i < keys.length; i++) {
                console.log(keys[i]);
                memberlist.autoFeed(keys[i]);
            }
        }

        // fetch and feed
        /*
        new Request.JSON({'url': 'json.html', 'onComplete': function(j) {
        j.each(tlist2.autoFeed, tlist2);
        }}).send();
        */
        return;
    }
});
