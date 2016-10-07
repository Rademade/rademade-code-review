app.controller 'appCtrl', [
  '$scope','$rootScope','UserState', '$state','DateService', 'Relation', 'Country', 'City', 'ProfileOptions', 'config', 'Client', 'Friend',
  ($scope, $rootScope, UserState, $state, DateService, Relation, Country, City, ProfileOptions, config, Client, Friend) ->

    $scope.waitingForLogin = true

    # Settings

    $rootScope.domain = config.domain

    # Dynamic load
    $rootScope.avatarLoaded = false
    Country.get().then (countries) -> $rootScope.countries = countries
    City.get().then (data) -> $rootScope.cities = data.cities
    Relation.allRelations (relations)->  $scope.relations = relations

    _setCurrentUser = (user)->
      $scope.waitingForLogin = false
      return false unless user
      $rootScope.currentUser = user
      $rootScope.currentUserClone = user # TODO check for real clone
      Friend.userFriends(user.id, Friend.DEFAULT_COUNT_OF_FRIENDS).then (friends) ->
        $rootScope.currentUserFriends = friends if user.id == $rootScope.currentUser.id

      $rootScope.isInSubscribers() if $rootScope.isInSubscribers
      $rootScope.currentUser.countOfNewMessages = 0 unless $rootScope.currentUser.countOfNewMessages

      Client.subscribe "/messenger/#{$rootScope.currentUser.fayeChannel}", (data) ->
        if data.message
          $rootScope.currentUser.countOfNewMessages++
          $rootScope.$apply()

    UserState.currentUser (user)->  _setCurrentUser(user)

    $scope.isLoggedIn = -> $scope.currentUser
    $scope.showFriendsButton = -> !$rootScope.isCurrentUser() && $scope.isLoggedIn()
    $rootScope.isCurrentUser = ->
        $rootScope.currentUser.compare $rootScope.user if $rootScope.currentUser and $rootScope.user

    $scope.setAuthToken = (apiKey)->
      UserState.setSession(apiKey)
      UserState.currentUser (user) -> _setCurrentUser(user)

    window.addEventListener "message", (event)->
      for key, key_args of event.data
        switch key
           when 'setAuthToken' then  $scope.setAuthToken(key_args); break
      window.location = '/video-chat' if $rootScope.redirectAfterLogin

    $scope.logout = ->
      $rootScope.currentUser = null
      UserState.logOut()

    # Popups block
    $rootScope.userState = 'public.user({ alias : user.alias || user.id })'

    $scope.isHomePage = window.location.pathname == '/'
    $scope.$on '$stateChangeStart', (e, toState)->
      $scope.isHomePage = toState.url == '/'

    $rootScope.$on '$stateChangeSuccess', ->
      $('.wrapper-box').scrollTop(0)

]