class RedmineService
  # Method to create a ticket in Redmine from an issue
  def create_redmine_issue(issue, project_key, default_tracker_id)
    begin
    # Retrieve project based on SonarQube project key
    project = Project.find_by(name: project_key)
    if project.blank?
      Rails.logger.error("Project not found in Redmine with key: #{project_key}")
      project = Project.new(
        name: project_key,
        identifier: project_key.parameterize,
        description: "Project created for SonarQube integration",
        is_public: true,
        status: Project::STATUS_ACTIVE
      )
      if project.save
        Rails.logger.info("Project successfully created in Redmine: #{project.name}")
      else
        Rails.logger.error("Error creating project in Redmine: #{project.errors.full_messages}")
    end
  else
    Rails.logger.info("Project already exists: #{project_key}")
  end
    
    # Check if author is present in the payload
    author_login = issue['author']
    Rails.logger.info("author found in sonarqube: #{author_login}")
    user = nil
    author_open_ticket = User.find_by(login: 'admin')
    if author_login.present? 
      # Search Redmine user by login
      user = User.find_by(login: author_login)
      if user.nil?
        user = User.find_by(login: 'admin')
        Rails.logger.error("user not found in Redmine login, use a default user: #{user}")
      end
    else
      user = User.find_by(login: 'admin')
      Rails.logger.error("user not found or invalid, use a deafult user: #{user}")
    end
    Rails.logger.info("issue assigned to: #{user} id: #{user.id}")
     
    # Creating the issue in Redmine
    redmine_issue = Issue.new(
      project_id: project.id,
      subject: "SonarQube Issue: #{issue['key']}",
      description: "Error: #{issue['message']}\nFile: #{issue['component']}\nLine: #{issue['line']} \nType: #{issue['type']}",
      priority_id: get_priority(issue['severity']),
      author_id: author_open_ticket.id, 
      status_id: 1, 
      tracker_id: default_tracker_id,
      assigned_to_id: user.id,
      start_date: Date.today
    )
    
    if redmine_issue.save
      Rails.logger.info("Issue successfully created in Redmine: #{redmine_issue.id}")
    else
      Rails.logger.error("Error creating issue in Redmine: #{redmine_issue.errors.full_messages}")
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Record not found error: #{e.message}")
    puts("Record not found error: #{e.message}")

  rescue StandardError => e
    Rails.logger.error("Unexpected error in create_redmine_issue: #{e.message}")
    puts("Unexpected error in create_redmine_issue: #{e.message}")
  end
end
  
  # mapping between redmine priority and sonarqube severity
  def get_priority(severity)
    priorities = {
      'BLOCKER' => 5,
      'CRITICAL' => 4,
      'MAJOR' => 3,
      'MINOR' => 2,
      'INFO' => 1
    }
    priorities[severity] || 1
  end
end
