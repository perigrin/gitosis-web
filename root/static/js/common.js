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
    },
    openForm: function(e, element) {
        new Event(e).stop();
        $(element).setStyles({
            visibility: 'visible',
            opacity:    '0'
        }).fade('in');
    },
    closeForm: function(e, element) {
        new Event(e).stop();
        $(element).fade('out').chain(function(form) { form.reset(); form.setStyle('visibility', 'hidden') });
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

var Page_Project_UserList = new Class({
    Extends: PageWidget,
	Implements: [Options, Events],
    fx: {
        newUser: $empty(),
        addUser: $empty()
    },
    postInitialize: function() {
        console.log("Initializing");
        this.formValidator = new FormValidator($('AddNewUser'));
        var newUser = $('btnNewUser');
        var newUserForm = $('AddNewUser');
        var addUser = $('btnAddUser');
        var addUserForm = $('AddExistingUser');
        newUser.addEvent('click', this.openForm.bindWithEvent(this, newUserForm));
        addUser.addEvent('click', this.openForm.bindWithEvent(this, addUserForm));
        newUserForm.getElement('button[name="cancel"]').addEvent('click', this.closeForm.bindWithEvent(this, newUserForm));
        addUserForm.getElement('button[name="cancel"]').addEvent('click', this.closeForm.bindWithEvent(this, addUserForm));
        var addUserComplete = new Autocompleter.Local($('existingName'), this.options.ssh_keys);

        return;
    }
});

var Page_Project_Repo = new Class({
    Extends: PageWidget,
	Implements: [Options, Events],
    postInitialize: function() {
        this.formValidator = new FormValidator($('AddNewRepo'));
        var newRepo = $('btnNewRepo');
        var newRepoForm = $('AddNewRepo');
        addRepo.addEvent('click', this.openForm.bindWithEvent(this, addRepoForm));
        addRepoForm.getElement('button[name="cancel"]').addEvent('click', this.closeForm.bindWithEvent(this, addRepoForm));
        return;
    }
});
