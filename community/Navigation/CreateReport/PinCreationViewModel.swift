//
//  PinCreationViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 09.03.2022.
//

import RxSwift
import RxCocoa
import CoreLocation
import FirebaseFirestore

class PinCreationViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let sendTap: Driver<Void>
    }
    
    struct Output {
        let sendTapped: Driver<Void>
    }
    
    enum MediaCollectionType {
        case add
        case photo(UIImage?)
        case video(URL)
    }
    
    weak var sendTrigger: PublishSubject<Void>?
    let nameRelay = BehaviorRelay<String>(value: "")
    let descriptionRelay = BehaviorRelay<String>(value: "")
    
    var coordinates: CLLocationCoordinate2D! {
        didSet {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let self = self else { return }
                LocationManager.shared.geocode(coordinates: self.coordinates) { name in
                    DispatchQueue.global(qos: .utility).async {
                        self.locationObservable.accept(name)
                    }
                }
            }
        }
    }
    
    let mediaObservable = BehaviorRelay<[MediaCollectionType]>(value: [.add])
    let locationObservable = PublishRelay<String?>()
    private var router: PinCreationRouter!
    
    private var uploadItemRepository: UploadItemRepository
    private var queueItemRepository: QueueItemRepository
    
    init(router: PinCreationRouter, sendTrigger: PublishSubject<Void>) {
        self.router = router
        self.sendTrigger = sendTrigger
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let queueItemMapper = QueueItemMapperImpl()
        let uploadItemMapper = UploadItemMapperImpl()
        let queueDataSource = QueueItemDataSourceImpl(container: container, queueItemMapper: queueItemMapper, uploadItemMapper: uploadItemMapper)
        queueItemRepository = QueueItemRepositoryImpl(dataSource: queueDataSource)
        
        let uploadDataSource = UploadItemDataSourceImpl(container: container, mapper: uploadItemMapper)
        uploadItemRepository = UploadItemRepositoryImpl(dataSource: uploadDataSource)
    }
    
    func acceptNewMedia(_ media: MediaCollectionType) {
        mediaObservable.accept([.add, media] + mediaObservable.value[1...])
        router.dismiss()
    }
    
    func transform(_ input: Input) -> Output {
        
        let sendTapped = input.sendTap
            .do(onNext: { [weak self] in
                guard let self = self, !self.nameRelay.value.isEmpty else { return }
                
                let id = UUID().uuidString
                let pin = Pin(
                    id: id,
                    name: self.nameRelay.value,
                    description: self.descriptionRelay.value,
                    coordinates: GeoPoint(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude)
                )
                StorageManager.shared.createRecord(data: pin, collection: StorageManager.Collection.pins)
                
                DispatchQueue.global(qos: .utility).async {
                    let queue = QueueItem(id: id, timestamp: Date())
                    switch self.queueItemRepository.createQueueItem(queue) {
                    case .failure(let error):
                        print("🔴 Error creating a queue: ", error)
                        return
                    default:
                        break
                    }
                    
                    for media in self.mediaObservable.value {
                        var item: UploadItem?
                        let itemId = UUID().uuidString
                        switch media {
                        case .photo(let image):
                            if let data = image?.jpegData(compressionQuality: 0.5) {
                                item = UploadItem(id: itemId, type: .image("\(UUID().uuidString).jpeg"), data: data)
                            }
                        case .video(let url):
                            if let data = try? Data(contentsOf: url) {
                                item = UploadItem(id: itemId, type: .video(url.lastPathComponent), data: data)
                            }
                        default:
                            break
                        }
                        
                        if let item = item {
                            _ = self.queueItemRepository.set(item: item, forQueueId: queue.id)
                        }
                    }
                    
                    UploadQueueManager.shared.uploadQueueItems(queue)

                    DispatchQueue.main.async {
                        self.sendTrigger?.on(.next(()))
                    }
                    
                }
            })
        
        return Output(
            sendTapped: sendTapped
        )
    }
    
}
