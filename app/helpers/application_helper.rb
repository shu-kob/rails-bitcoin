module ApplicationHelper
    def document_title
        if @title.present?
            "#{@title} - Blockchain Explorer"
        else
            "Blockchain Explorer"
        end
    end
end
