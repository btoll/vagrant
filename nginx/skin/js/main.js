/* eslint-disable curly */

document.addEventListener('DOMContentLoaded', function () {
    var links = document.querySelectorAll('a');
    var title;

    function removeTitle() {
        // Neuter the default browser behavior.
        title = this.title;
        this.title = '';
    }

    function resetTitle() {
        // Restore the title.
        this.title = title;
    }

    for (var i = 0, len = links.length; i < len; i++) (function (i) {
        var link = links[i];

        link.addEventListener('mouseover', removeTitle);
        link.addEventListener('mouseout', resetTitle);
    }(i));
});

