var login = {
    formHeight: '1.76em',
    loginText: 'Log In',
    cancelText: 'Cancel',
    show: function(event) {
        $('#header .login').slideDown();

        var content = $('#page-content');
        var newMargin = this.formHeight;
        content.animate({'margin-top': newMargin});

        var loginButton = $('a.login-btn');
        loginButton.unbind();
        loginButton.click($.proxy(this.hide, this));
        loginButton.children('.btn').text(this.cancelText);

        event.preventDefault(); // Do not navigate away from this page.
    },
    hide: function(event) {
        $('#header .login').slideUp();

        var content = $('#page-content');
        var newMargin = 0;
        content.animate({'margin-top': newMargin});

        var loginButton = $('a.login-btn');
        loginButton.unbind();
        loginButton.click($.proxy(this.show, this));
        loginButton.children('.btn').text(this.loginText);

        event.preventDefault(); // Do not navigate away from this page.
    }
}

var onLoad = function () {
    $('a.login-btn').click($.proxy(login.show, login));
};
$(document).ready(onLoad);
$(document).on('page:load', onLoad);
