//
//  AuthProvider.swift
//  ober driver
//
//  Created by Austin Glugla on 2/2/17.
//  Copyright © 2017 Portable Hats. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email";
    static let WRONG_PASSWORD = "Wrong Password";
    static let PROBLEM_CONNECTING = "Problem connecting to database";
    static let USER_NOT_FOUND = "No User with that Login";
    static let EMAIL_ALREADY_IN_USE = "Please use a different email";
    static let WEAK_PASSWORD = "Password Should be at least 6 characters";
}

class AuthProvider {
    
    
    private static let _instance = AuthProvider();
    
    static var Instance: AuthProvider {
        return _instance;
    }
    
    func login (withEmail: String, password: String, loginHandler:
        LoginHandler?) {
        FIRAuth.auth()?.signIn(withEmail: withEmail, password: password, completion: {(user,error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
            }else{
                loginHandler?(nil);
            }
            
        });
        
    }//Login Function
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?){
        
        FIRAuth.auth()?.createUser(withEmail: withEmail, password: password, completion: {(user, error)in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
            }else {
                
                if user?.uid != nil {
                    
                    // store the user to database
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password);
                    
                    // login the user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler);
                }
                
            }
            
        })
    }//Sign Up Function
    
    func logOut() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            do{
                try FIRAuth.auth()?.signOut();
                return true;
            }catch{
                return false;
            }
        }
        return true;
    }
    
    private func handleErrors(err: NSError, loginHandler:
        LoginHandler?) {
        if let errCode = FIRAuthErrorCode(rawValue: err.code) {
            
            switch errCode {
                
            case .errorCodeWrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD);
                break;
            case .errorCodeInvalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL);
                break;
            case .errorCodeUserNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND);
                break;
            case .errorCodeEmailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE);
                break;
            case .errorCodeWeakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD);
                break;
                
            default:
                break;
            }
            
            
        }
    }
}

//Authentication Class




