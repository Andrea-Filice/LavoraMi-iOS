//
//  BiometricAuth.swift
//  LavoraMi
//
//  Created by Andrea Filice on 05/02/26.
//

import LocalAuthentication

struct BiometricAuth {

    static func authenticate(onSuccess: @escaping () -> Void,
                             onFailure: @escaping (Error?) -> Void) {

        let context = LAContext()
        context.localizedCancelTitle = "Annulla"

        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &error) else {
            onFailure(error)
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Autenticazione richiesta"
        ) { success, authError in
            DispatchQueue.main.async {
                if success {
                    onSuccess()
                } else {
                    onFailure(authError)
                }
            }
        }
    }
}
