# SQA Unit Test Scripts
**Course**: Software Quality Assurance
**Implementer**: Phan Anh
**Features**: Authentication Verification, Current Role Evaluation Strategy, and Token Validity Logic

## Description
This repository contains the isolated unit test scripts designed to validate the Auth flow and Role evaluation algorithms of a Nuxt 3 (Vue.js) application. The tests are built using **Vitest** and **Happy-DOM**.

## Test Cases Executed
1. `TC-AUTH-01`: Verify default role selection prioritization
2. `TC-AUTH-02`: Validate caching stale local role clearance
3. `TC-AUTH-03`: Verify Email Verification Token Success
4. `TC-AUTH-04`: Verify Email Verification Token Invalid Format
5. `TC-AUTH-05`: Reset Password Token timeout response
6. `TC-AUTH-06`: Redirect Logic (Unauthenticated routing)
7. `TC-AUTH-07`: Redirect Logic (Authenticated routing bypass)
8. `TC-AUTH-08`: Logout State Clean-Up sequence (`clearStore`)
9. `TC-AUTH-09`: Token persistence clean logic (`clearToken`)

## Run Tests Locally
```bash
npm install
npm run coverage
```
