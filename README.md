# Khroma
ALPHA camp demo day project  
An website with color matching algorithm to help user choose clothes.

## How to run it on local

1.  Install all required Ruby GEM
```
$ bundle install
```

2.  Manually add ./config/facebook.yml with app_id and secret. Content inside would be be as follows.
```
development:
  app_id: YOUR_FB_APP_ID
  secret: FB_APP_SECRET
```
Replace **YOUR_FB_APP_ID** and **FB_APP_SECRET** with what you got from [Facebook for developers ](https://developers.facebook.com)

3.  Setup for database
```
$ rails dev:fake_all
```

4.  Start server
```
$ rails s
```