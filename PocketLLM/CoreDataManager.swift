import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    
    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "PocketLLM")  // 모델 이름 주의!
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("❌ Core Data 스토어 로드 실패: \(error.localizedDescription)")
            } else {
                print("✅ Core Data 로드 성공: \(description.url?.absoluteString ?? "")")
            }
        }
    }
    
    func deleteAllConversations() {
        let context = CoreDataManager.shared.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Conversation.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("✅ 모든 Conversation 삭제 완료")
        } catch {
            print("❌ 삭제 실패: \(error)")
        }
    }


    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("❌ Core Data 저장 실패: \(error.localizedDescription)")
            }
        }
    }
}
