# uwu_pixel_client

![demo](assets/demo.gif)


# Run the project

#### UPDATE DOCKERFILE

First start the server

With the dockerfile just use those two commands :

```bash
docker build -t uwu_client .
docker run -it -p 8090:80 --rm --name uwu_client uwu_client 
```


go to localhost:8090 to run a client


then :
```
flutter pub get
dart run build_runner build
flutter run # --release if you want
```


# Note
Grid size has been reduced for visibility since I didn't implemented a zoom but should work as fine with a bigger one like 1000x700
