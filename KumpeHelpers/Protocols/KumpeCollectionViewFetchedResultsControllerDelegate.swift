//
//  KumpeCollectionViewFetchedResultsControllerDelegate.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 7/10/22.
//

import UIKit
import CoreData

class FetchedResultsCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {

    private var sectionChanges = [(type: NSFetchedResultsChangeType, sectionIndex: Int)]()
    private var itemChanges = [(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)]()

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        sectionChanges.append((type, sectionIndex))
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        itemChanges.append((type, indexPath, newIndexPath))
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        collectionView?.performBatchUpdates({

            for change in self.sectionChanges {
                switch change.type {
                case .insert: self.collectionView?.insertSections([change.sectionIndex])
                case .delete: self.collectionView?.deleteSections([change.sectionIndex])
                default: break
                }
            }

            for change in self.itemChanges {
                switch change.type {
                case .insert: self.collectionView?.insertItems(at: [change.newIndexPath!])
                case .delete: self.collectionView?.deleteItems(at: [change.indexPath!])
                case .update: self.collectionView?.reloadItems(at: [change.indexPath!])
                case .move:
                    self.collectionView?.deleteItems(at: [change.indexPath!])
                    self.collectionView?.insertItems(at: [change.newIndexPath!])
                @unknown default:
                    return
                }
            }

        }, completion: { finished in
            self.sectionChanges.removeAll()
            self.itemChanges.removeAll()
        })
    }

}
