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

    $('span.sitem').hover(
        // hover In
        function () {
            var target = $(this);
            var icons = target.find('.icon');
            icons.show();
        },
        // hover Out
        function () {
            var target = $(this);
            var icons = target.find('.icon');
            icons.hide();
        }
    );
    var btn = document.querySelectorAll('.password-copy');
    var clipboard = new Clipboard(btn);

    var time = new Date().getTime();
    $(document.body).bind("mousemove keypress", function (e) {
        time = new Date().getTime();
    });

    function refresh() {
        if (new Date().getTime() - time >= 60000)
            window.location.reload(true);
        else
            setTimeout(refresh, 10000);
    }

    setTimeout(refresh, 10000);
});
