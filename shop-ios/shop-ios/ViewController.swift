//
//  ViewController.swift
//  shop-ios
//
//  Created by Julio Molina on 3/26/19.
//  Copyright © 2019 Synapsis Solutions. All rights reserved.
//

import UIKit
import SynapPay

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
        SynapPayButton.setEnvironment(.development)
        
        self.paymentForm.configure(
            // Seteo de los campos de autenticación de seguridad
            authenticator: self.setAuthentication(),
            
            // Seteo de los campos de la transacción
            transaction: self.setTransaction(),
            
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
    
    func setAuthentication() -> SynapAuthenticator{
        // Referencie el objeto de autenticación
        var authenticator = SynapAuthenticator()
        
        // Seteo de identificador con el APIKey del comercio
        authenticator.identifier = "4"
        
        // La firma se debe generar en el servidor del comercio utilizando la función criptográfica SHA-512
        // La firma permite verificar la integridad de la transacción
        authenticator.signature = "8A9F904FF3B689CFB587B7D2A3B347B2204C9029FC7D9FF64101715BD65E9F4A5E2663A38F20D66005AB0274B070F4221B48BF4B570828ADD44121293EC2C532"
        return authenticator
    }
    
    func setTransaction() -> SynapTransaction{
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
        var wallet = SynapWallet()
        wallet.userIdentifier = customer.email
        features.wallet = wallet
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
}

