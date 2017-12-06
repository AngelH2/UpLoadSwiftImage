import UIKit

typealias Parameters =  [String: String]

class ViewController: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
URLSessionDelegate,
URLSessionTaskDelegate,
URLSessionDataDelegate{

    @IBOutlet weak var img_image: UIImageView!
    @IBOutlet weak var progress_view: UIProgressView!
    @IBOutlet weak var lbl_carga: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reset()
    }
    
    @IBAction func btn_seleccionar(_ sender: Any) {
        self.reset()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func generateBoundary() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    @IBAction func btn_cargar(_ sender: Any) {
        self.uploadImage()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imagen = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            self.img_image.image = imagen
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func reset()
    {
        self.progress_view.progress = 0
        self.lbl_carga.text = "0%"
    }
    
    func uploadImage()
    {
        if let imagen = self.img_image.image
        {
            var array_image = [Media]()
            
            if let mediaImage = Media(withImage: imagen, forkey: "image[]")
            {
                array_image.append(mediaImage)
            }
            
            /* More images
            if let image2 = UIImage(named: "imagen2")
            {
                if let mediaImage = Media(withImage: imagen2, forkey: "image[]")
                {
                    array_image.append(mediaImage)
                }
            }*/
            
            print("\n\nCount of images: \(array_image.count)")
            
            let boundary = self.generateBoundary()
            
            var url_request = URLRequest(url: URL(string: "IP")!)
            url_request.httpMethod = "POST"
            url_request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            url_request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
            
            let request_data = self.createData(params: nil, media: array_image, boundary: boundary)
            
            let configuracion = URLSessionConfiguration.default
            let url_sesion = URLSession(configuration: configuracion,
                                        delegate: self,
                                        delegateQueue: OperationQueue.main)
            
            let task = url_sesion.uploadTask(with: url_request, from: request_data)
            task.resume()
        }
    
    }
    
    func createData(params: Parameters?,
                    media: [Media]?,
                    boundary: String) -> Data
    {
        let lineBreak = "\r\n"
        var httpBody = Data()
        
        if let parameters = params
        {
            for (key, value) in parameters
            {
                httpBody.append("--\(boundary + lineBreak)")
                httpBody.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                httpBody.append("\(value + lineBreak)")
            }
        }
        
        if let media_data = media
        {
            for photo in media_data
            {
                httpBody.append("--\(boundary + lineBreak)")
                httpBody.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                httpBody.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                httpBody.append(photo.data)
                httpBody.append(lineBreak)
            }
        }
        httpBody.append("--\(boundary)--\(lineBreak)")
        return httpBody
    }
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64)
    {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        self.progress_view.progress = uploadProgress
        
        let progressPercent = Int(uploadProgress*100)
        self.lbl_carga.text = "\(progressPercent)%"
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.mensaje(mensaje: (error?.localizedDescription)!)
    }
    
    func mensaje(mensaje: String)
    {
        let alerta = UIAlertController(title: "Alerta",
                                       message: mensaje,
                                       preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alerta, animated: true, completion: nil)
    }
    
    /*
     PHP CODE ========
     if(is_array($_FILES["image"]["name"]) || is_object($_FILES["image"]["name"]))
     {
         foreach(($_FILES['image']['name']) as $key=>$val)
         {
             $file_name = $key.$_FILES['image']['name'][$key];
             $file_tmp =$_FILES['image']['tmp_name'][$key];
     
             $target_dir = "imagenes/".$file_name.".jpg";
             if (move_uploaded_file($file_tmp, $target_dir))
             {
                 //
             }
         }
     }
     */
}
extension Data
{
    mutating func append(_ string: String)
    {
        if let data = string.data(using: .utf8)
        {
            append(data)
        }
    }
}
































