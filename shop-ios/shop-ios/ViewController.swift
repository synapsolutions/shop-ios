//
//  ViewController.swift
//  shop-ios
//
//  Created by Julio Molina on 3/26/19.
//  Copyright © 2019 Synapsis Solutions. All rights reserved.
//

import UIKit
import SynapPay
import CommonCrypto

class ViewController: UIViewController {
    
    @IBOutlet weak var synapFormContainer: UIView!
    @IBOutlet weak var synapForm: UIView!
    @IBOutlet weak var synapButton: UIButton!
    var paymentForm: SynapPayButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Oculte el contenedor principal, hasta que la acción de apertura sea ejecutada
        self.synapFormContainer.isHidden = true
    }
    
    @IBAction func startPayment(_ sender: Any) {
        // Muestre el contenedor principal
        self.synapFormContainer.isHidden = false
        
        // Crea el objeto del widget de pago
        self.paymentForm = SynapPayButton.create(view: self.synapForm)
        
        // Seteo del ambiente ".sandbox" o ".production"
        SynapPayButton.setEnvironment(.sandbox)
        let transaction=self.buildTransaction()
        let authenticator=self.buildAuthentication(transaction)
        self.paymentForm.configure(
            // Seteo de los campos de autenticación de seguridad
            authenticator: authenticator,
            
            // Seteo de los campos de la transacción
            transaction: transaction,
            
            // Manejo de los campos de respuesta
            success: {
                (response) in
                let resultCode = response.result!.code
                let resultMessage = response.result!.message
                if (resultCode == "AUTHORIZED") {
                    // Agregue el código según la experiencia del cliente para la autorización
                    self.showMessage(message: resultMessage!)
                }
                else if (resultCode == "DENIED") {
                    // Agregue el código según la experiencia del cliente para la denegación
                    self.showMessage(message: resultMessage!)
                }
                else {
                    // Agregue el código según la experiencia del cliente para un error
                    self.showMessage(message: resultMessage!)
                }
        },
            failed: {
                (response) in
                let messageText = response.message!.text!
                // Agregue el código de la experiencia que desee visualizar en un error
                self.showMessage(message: messageText)
            }
        )
    }
    
    func buildAuthentication(_ transaction: SynapTransaction) -> SynapAuthenticator{
        let identifier = "4779d88b-bc30-481b-bb2b-a2a21d60fdf1"
        
        // La signatureKey y la función de generación de firma debe usarse e implementarse en el servidor del comercio utilizando la función criptográfica SHA-512
        // solo con propósito de demostrar la funcionalidad, se implementará en el ejemplo
        // (bajo ninguna circunstancia debe exponerse la signatureKey y la función de firma desde la aplicación porque compromete la seguridad)
        let signatureKey = "zY6vkX7#E81C+9z6X1_pzz*hOx!g+DAp"
        let signature = generateSignature(transaction: transaction, identifier: identifier, signatureKey: signatureKey)
        
        // Referencie el objeto de autenticación
        var authenticator = SynapAuthenticator()
        
        // Seteo de identificador del comercio
        authenticator.identifier = identifier
        
        // Seteo de firma, que permite verificar la integridad de la transacción
        authenticator.signature = signature
        
        return authenticator
    }
    
    func buildTransaction() -> SynapTransaction{
        // Genere el número de orden
        let number = String(getCurrentMillis());
        
        // Referencie al objeto país
        var country = SynapCountry()
        // Seteo del código de país donde se procesará la transacción
        country.code = "PER"
        
        // Referencie al objeto moneda
        var currency = SynapCurrency()
        // Seteo del código de moneda en la que se procesará la transacción
        currency.code = "PEN"
        
        // Referencie al objeto cliente
        var customer = SynapPerson()
        
        // Referencie al objeto documento del cliente
        var customerDocument = SynapDocument()
        // Seteo del tipo y número de documento
        customerDocument.type = "DNI"
        customerDocument.number = "44556677"
        
        // Referencie al objeto dirección del cliente
        var customerAddress = SynapAddress()
        // Seteo del pais, departamento (levels[0]), provincia (levels[1]) , distrito (levels[2]), dirección y zip del cliente
        customerAddress.country = "PER"
        customerAddress.levels = [String]()
        customerAddress.levels?.append("150000")
        customerAddress.levels?.append("150100")
        customerAddress.levels?.append("150101")
        customerAddress.line1 = "Ca Carlos Ferreyros 180"
        customerAddress.zip = "051014"
        
        // Seteo de nombre, apellido, dirección, email, teléfono y documento del cliente
        customer.name = "Julio"
        customer.lastName = "Molina"
        customer.address = customerAddress
        customer.email = "javier.perez@synapsolutions.com"
        customer.phone = "999888777"
        customer.document = customerDocument
        
        // Seteo de los datos de envío
        let shipping = customer
        // Seteo de los datos de facturación
        let billing = customer
        
        // Referencie al objeto producto
        var productItem = SynapProduct()
        // Seteo de los datos de producto
        productItem.code = "123"
        productItem.name = "Producto prueba"
        productItem.quantity = "1"
        productItem.unitAmount = "1.00"
        productItem.amount = "1.00"
        
        // Referencie al objeto lista producto
        var products = [SynapProduct]()
        // Seteo de los datos de lista de producto
        products.append(productItem)
        
        // Referencie al objeto orden
        var order = SynapOrder();
        // Seteo de los datos de orden
        order.number = number;
        order.amount = "11.00"
        order.country = country
        order.currency = currency
        order.products = products
        order.customer = customer
        order.shipping = shipping
        order.billing = billing
        synapButton.titleLabel?.text = "Pagar " + order.currency!.symbol! + order.amount!

        // Referencie al objeto configuración
        var settings = SynapSettings();
        // Seteo de los datos de configuración
        settings.brands = ["VISA","MSCD"];
        settings.language = "es_PE";
        settings.businessService = "MOB";
        
        // Referencie al objeto transacción
        var transaction = SynapTransaction();
        // Seteo de los datos de transacción
        transaction.order = order;
        transaction.settings = settings;
        
        // Wallet
        var features = SynapFeatures()
        var cardStorage = SynapCardStorage()
        cardStorage.userIdentifier = "javier.perez@synapsolutions.com"
        features.cardStorage = cardStorage
        transaction.features = features
        
        return transaction;
    }
    
    @IBAction func synapActionPay(_ sender: Any) {
        self.paymentForm.pay()
    }
    
    // Genera número de orden
    func getCurrentMillis()->Int64{
        return  Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    
    // Muestra el mensaje de respuesta
    func showMessage(message:String){
        DispatchQueue.main.async {
            let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            alertMessage.addAction(cancelAction)
            self.present(alertMessage, animated: true, completion: nil)
        }
    }
    
    // La signatureKey y la función de generación de firma debe usarse e implementarse en el servidor del comercio utilizando la función criptográfica SHA-512
    // solo con propósito de demostrar la funcionalidad, se implementará en el ejemplo
    // (bajo ninguna circunstancia debe exponerse la signatureKey y la función de firma desde la aplicación porque compromete la seguridad)
    private func generateSignature(transaction: SynapTransaction, identifier: String, signatureKey: String) -> String{
        
        let orderNumber = transaction.order!.number!
        let currencyCode = transaction.order!.currency!.code!
        let amount = transaction.order!.amount!
        
        let rawSignature = identifier + orderNumber + currencyCode + amount + signatureKey
        let signature = sha512Hex(rawSignature)
        return signature
    }
    
    func sha512Hex(_ value: String) -> String {
        let data = value.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes({
            _ = CC_SHA512($0, CC_LONG(data.count), &digest)
        })
        return digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
    }

}

