app.service('UserState', [
  'Session', 'User','CookiesService',
  (Session, User, CookiesService)->

    user: null,
    userPromise: null,
    session: null

    currentUser : (callback)->
      if @user instanceof User
         callback(@user)
         return
      unless CookiesService.setCookie('API_KEY')
        callback()
        return

      @session ||= Session.get()
      @session.then (data)->
       unless data.userId
         callback(@user)
         return false
       CookiesService.setCookie('userId', data.userId)
       @userPromise ||= User.get(data.userId)
       # TODO extract private fail and sucess methods
       @userPromise.then (user) =>
         user.fayeChannel = data.channel
         @user = user
         callback(user)
       ,(error)-> callback()
      ,(error)-> callback()

    setSession : (token)->
      @session = null;
      CookiesService.setCookie('API_KEY', token )

    logOut : ->
      @user = null
      CookiesService.deleteCookie('API_KEY')
      CookiesService.deleteCookie('language')

])