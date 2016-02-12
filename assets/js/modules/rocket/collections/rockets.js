define([

    'backbone',
    'modules/rocket/collections/rocket',

], function(Backbone, Model){
    var Collection = Backbone.Collection.extend({
        model: Model,
        url: '/index',
        sortParam: 'size',
        sortMode: 1,
        comparator: function(a,b) {
            if(a.get(this.sortParam) > b.get(this.sortParam)) return -1*this.sortMode;
            if(a.get(this.sortParam) < b.get(this.sortParam)) return this.sortMode;
            return 0;
        }
    });

    return Collection;
});