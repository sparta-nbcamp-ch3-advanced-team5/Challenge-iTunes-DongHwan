# iTunesSearch

> iTunesSearch는 iTunes Search API를 통해 홈 화면에서 음악들을 보여주고, 추가적으로 팟캐스트, 영화 검색 기능을 제공하는 앱입니다.
<br/>

## 📋 프로젝트 개요

Autolayout과 View 간의 제약 관계를 익히고, 가변적인 데이터에 유연하게 대응하는 UI를 구성하는 것을 목표로 해리포터 책 시리즈 앱을 개발하였습니다.
<br/>

## ⏰ 프로젝트 일정

- **시작일**: 25/05/12  
- **종료일**: 25/05/19
<br/>

## 🛠️ 기술 스택

### 아키텍처
- MVVM

### 비동기 처리
- RxSwift
- Swift Concurrency

### API 통신
- URLSession

### 활용 API
- iTunes Search API

### UI Frameworks
- UIKit
- SnapKit(AutoLayout)
<br/>

## 📱 프로젝트 구현 기능

1. **홈 화면에서 음악 표시**  
   홈 화면에서 봄, 여름, 가을, 겨울 키워드에 따른 음악을 표시합니다.

2. **팟캐스트 및 영화 검색 기능 제공**  
   검색 키워드와 연관된 팟캐스트와 영화를 보여줍니다.

3. **이미지 메모리, 디스크 캐싱**
   네트워크 요청을 통해 로드한 이미지를 메모리, 디스크에 캐싱합니다.

5. **검색 결과 무한 스크롤**  
   검색 결과 화면에서 무한 스크롤을 지원합니다.
<br/>

## 프로젝트 설명

MVVM 패턴에 RxSwift, Swift Concurrency를 적용하여 구현한 iTunes Search 앱입니다.

### 아키텍처 및 라이브러리 선택

구현 과정에서 ViewController가 무거워지는 것을 방지하고 책임을 분리하기 위해 MVVM 패턴을 적용하였고, 이 과정에서 데이터 바인딩을 수월하게 하기 위해 RxSwift를 도입했습니다.
`URLSession`을 통한 API 통신 과정과 RxSwift를 사용하는 부분에 `async`, `await`, `Task`와 같은 Swift Concurrency를 사용하였는데, 전통적인 URLSession 코드에서 completionHandler를 활용한 코드 대비 가독성을 높이기 위함과 불필요한 네트워크 작업(네트워크에서 이미지 로딩을 기다리는 셀이 재사용 과정에 들어갔을 때)을 중단시키기 위함입니다.

### 키워드 설명

프로젝트에 적용한 키워드는 `추상화`, `재사용성` 그리고 `사용성 UX` 입니다.

- `추상화`

앱에서 iTunes Search API에 요청하는 미디어 타입은 음악, 팟캐스트, 영화 세 가지입니다. 각각 타입에 따라 수신받는 데이터가 조금씩 다른데, 이를 서로 다른 요청 메서드로 구현하는 대신 제네릭을 통해 추상화 과정을 거쳐서 하나의 요청 메서드로 구현하였습니다.

- `재사용성`

개발 과정에서 노래/팟캐스트/영화 제목, 아티스트/진행자/감독 이름과 썸네일 이미지와 같이 중복되는 UI들의 컴포넌트화를 통해 해당되는 UI에 적극 사용하여 재사용성을 높였습니다.

- `사용성 UX`

앱의 전반적인 가독성을 높이기 위해 앱스토어의 UI와 비슷하게 셀이나 섹션 배경에 그림자를 추가했고, 다크모드시 구분되도록 `secondarySystemGroupedBackground`를 배경색으로 적용하였습니다.
이미지 위에 글자가 표시되는 부분은 이미지에서 해당 부분에 그라데이션 적용을 하여 글자가 더욱 잘 보이도록 하였습니다.
또한, 무한 스크롤 데이터 혹은 이미지를 로딩 중일 때 `UIActivityIndicator`를 통해 사용자에게 로딩 중임을 알리도록 하였고, 이미지 로딩에 실패했을 경우 placeholder 이미지를 보여주도록 하였습니다.
성능 향상을 위해 네트워크 요청을 통해 로드한 이미지는 메모리, 디스크 캐싱을 실행하여 이후 로딩 시 빠르게 표시할 수 있도록 하였습니다.

### 메모리 관리 분석

<img width="1507" alt="스크린샷 2025-05-22 03 58 46" src="https://github.com/user-attachments/assets/de515de1-b9e3-4c61-a24b-c5751b95a5fe" />
Xcode의 Profile 기능을 통해 Instruments를 활용하여 메모리 누수 분석을 앱의 모든 화면에 걸쳐 진행하였지만, 메모리 누수는 나타나지 않았습니다.
<br/>

## 실행 이미지

|    구현 내용    |   스크린샷   |    구현 내용    |   스크린샷   |
| :-------------: | :----------: | :-------------: | :----------: |
| 홈 화면 | <img src = "https://github.com/user-attachments/assets/87af962b-dee4-45df-869a-e0983691c39c" width ="250"> | 검색 화면 | <img src = "https://github.com/user-attachments/assets/b7acb944-78ac-4b29-9753-b1cf263d53bc" width ="250"> |
| 팟캐스트, 영화<br/>섹션 | <img src = "https://github.com/user-attachments/assets/25f95669-311f-439d-b88a-3c1f54edb5b2" width ="250"> | 무한 스크롤 | <img src = "https://github.com/user-attachments/assets/a3aa7190-c679-4c6a-a0ac-206f220e0605" width ="250"> |
