# Khroma
ALPHA camp demo day project  
An website with color matching algorithm to help user choose clothes.

## User stories
1. 使用者在選擇好需要配色的衣服款式及顏色後，按下配色按鈕可以獲得基於配色法則所搭配的穿搭圖案以及適合的衣服
2. 使用者能夠在商品頁面查看同色系同款式的相似商品
3. 使用者登入後可收藏/移除收藏商品


## How to run it on local

1.  Install all required Ruby GEM
```
$ bundle install
```

2.  Manually add facebook.yml, google.yml and cloudinary.yml with app_id and secret under config folder. 

3.  Setup for database
```
$ rails dev:fake_all
```

4.  Start server
```
$ rails s
```

## ERD
![alt text](https://res.cloudinary.com/dec3rgj55/image/upload/v1523349661/ERD_phase2.png)