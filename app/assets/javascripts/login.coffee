#= require_self

$ ->
  $('p#login_password').on 'focusin', (e) => localStorage.clear()
