//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit

import AssignmentKit
import SoPersistent
import TooLegit
import ReactiveSwift
import SoLazy

struct AssignmentViewModel: TableViewCellViewModel {
    let name: String
    let subtitle: String
    
    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(UINib(nibName: "AssignmentCell", bundle: Bundle(for: AppDelegate.self)), forCellReuseIdentifier: "AssignmentCell")
    }
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = subtitle
        return cell
    }
    
    init(assignment: Assignment) {
        name = assignment.name + " \(assignment.gradingPeriodID ?? "none")"
        subtitle = assignment.due.flatMap({ DateFormatter.MediumStyleDateTimeFormatter.string(from: $0)}) ?? "No Due Date"
    }
}

class AssignmentList: FetchedTableViewController<Assignment> {
    
    let session: Session
    let courseID: String
    
    init(session: Session, courseID: String) throws {
        self.session = session
        self.courseID = courseID
        super.init()

        let collection = try Assignment.collectionByDueStatus(session, courseID: courseID)
        let refresher = try Assignment.refresher(session, courseID: courseID)
        prepare(collection, refresher: refresher, viewModelFactory: AssignmentViewModel.init)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assignment = collection[indexPath]
        do {
            let deets = try AssignmentDetailViewController.new(session, courseID: assignment.courseID, assignmentID: assignment.id)
            navigationController?.pushViewController(deets, animated: true)
        } catch let e as NSError {
            ErrorReporter.reportError(e, from: self)
        }
    }

}
