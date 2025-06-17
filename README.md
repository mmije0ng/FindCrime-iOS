# FindCrime-iOS

## 🚨 Introduce
**FindCrim**e은 Swift로 개발된 **iOS 애플리케이션**으로, **공공데이터를 기반으로 범죄 종류와 지역별 범죄 건수 및 위험도**를 지도를 통해 시각적으로 확인할 수 있습니다.
또한, 사용자의 현재 위치를 중심으로 **주변 경찰서 정보**를 지도에 표시하며, 범죄 종류 및 지역을 선택하여 **사건 제보**를 할 수 있습니다.  

**사용 공공데이터**: https://www.data.go.kr/data/3074462/fileData.do

&nbsp;
## 🔧 Tech Stack
<p>
  <img src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white">
  <img src="https://img.shields.io/badge/SwiftUI-0A84FF?style=for-the-badge&logo=swift&logoColor=white">
  <img src="https://img.shields.io/badge/SpringBoot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white"> 
  <img src="https://img.shields.io/badge/Java-007396?style=for-the-badge&logo=openjdk&logoColor=white">
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white">
  <img src="https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white">
  <img src="https://img.shields.io/badge/JWT-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white">
  <img src="https://img.shields.io/badge/공공데이터-005BAC?style=for-the-badge&logo=data&logoColor=white">
  <img src="https://img.shields.io/badge/Kakao-FFCD00?style=for-the-badge&logo=kakao&logoColor=black">
</p>


&nbsp;
## ✨ Main Feature

### OAuth2.0 기반 카카오 소셜 로그인
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/669cd8a8-014e-4e4d-bc5a-33f249f3bdd8" /></td>
    <td><img src="https://github.com/user-attachments/assets/396b8f58-bcb2-4c13-a777-5bc2e4e0d974" /></td>
  </tr>
</table>

&nbsp;
### 공공데이터 기반 범죄 통계 조회
공공데이터는 지역, 범죄 대분류, 범죄 중분류를 기준으로 조회할 수 있습니다.  
조회 조건이 '전국 전체'일 경우, 범죄 종류별 데이터를 전국 단위로 합산하여 제공하며,  
'서울 전체'와 같이 특정 시·도 전체를 선택한 경우에는 해당 지역 내 모든 구의 범죄 데이터를 범죄 종류별로 합산하여 제공합니다.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/2420dcc7-f617-4ce1-a324-90be744222ba" /></td>
    <td><img src="https://github.com/user-attachments/assets/be76f9ad-66cd-4942-b39e-a07dba09f0c1" /></td>
  </tr>
    <tr>
    <td><img src="https://github.com/user-attachments/assets/d86e1b8d-0b06-4c29-ad0c-a4a2d921a719" /></td>
    <td><img src="https://github.com/user-attachments/assets/5c73c89d-1bd5-4859-bb26-329fd0fa9945" /></td>
  </tr>
</table>

&nbsp;
### 주변 경찰서 찾기
카카오맵의 키워드 기반 장소 검색 라이브러리를 활용하여, 지도를 통해 사용자 주변의 경찰서 위치 정보를 확인할 수 있습니다.
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/07d5701e-35c8-4f6e-8060-c213304c6409" /></td>
    <td><img src="https://github.com/user-attachments/assets/81b63e10-267e-4808-9f55-93d010dce551" /></td>
  </tr>
</table>

&nbsp;
### 지역 사건 제보
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/4dd4bbb4-b4fe-49c3-8ac6-d71b967ee184" /></td>
    <td><img src="https://github.com/user-attachments/assets/14e882a9-1656-4de9-a591-3a640fd38ae1" /></td>
  </tr>
    <tr>
    <td><img src="https://github.com/user-attachments/assets/8974be93-d232-4586-96a6-44974e5ef6c1" /></td>
    <td><img src="https://github.com/user-attachments/assets/6b733578-1669-45c7-a191-03a30d21d53b" /></td>
  </tr>
</table>

&nbsp;
### 마이페이지
카카오 소셜 로그인 기반 프로필 사진, 이름, 이메일, 가입 날짜 확인 및 로그아웃
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/2ebceb02-3ca8-4c26-bfd0-05e8ab71f32f" /></td>
  </tr>
</table>

&nbsp;
## 🗂 ERD
<img width="840" alt="Image" src="https://github.com/user-attachments/assets/62cf06bd-12cf-4b44-bce6-917cd5bcdccb" />

&nbsp;
## 🛠 Architecture
<img width="840" alt="Image" src="https://github.com/user-attachments/assets/bcff92d4-10bb-4098-b97d-2894817b0fe2" />

&nbsp;
## BackEnd Repository
https://github.com/mmije0ng/FindCrime-SpringBoot
