$(function () {
    var test = $('a');
    $('a.password-copy').click(function (event) {
        event.preventDefault();
        console.log(arguments);
    });
    $('a.password-lock').click(function (event) {
        event.preventDefault();
        var target = $(event.target);
        var p = target.parent();
        var pass_span = p.find('span.vault-password');
        pass_span.toggle();
        if (target.hasClass('icon-unlock')) {
            target.toggleClass('icon-lock', true);
            target.toggleClass('icon-unlock', false);
        } else {
            target.toggleClass('icon-lock', false);
            target.toggleClass('icon-unlock', true);
        }
    });
});
