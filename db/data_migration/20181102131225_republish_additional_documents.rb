content_ids = [
  "07352332-c2bc-4b38-b8c1-72041b963faf",
  "5e168ba1-7631-11e4-a3cb-005056011aef",
  "b4c05c91-6ec0-47b9-9933-6616a13e61b7",
  "3a52dc00-d97b-476a-81f5-b1a955346655",
  "5f5c69e7-7631-11e4-a3cb-005056011aef",
  "5f5c080e-7631-11e4-a3cb-005056011aef",
  "5c8f4b2d-7631-11e4-a3cb-005056011aef",
  "5f5c1d75-7631-11e4-a3cb-005056011aef",
  "8508f8c9-38d3-41d4-a274-8b4cfb7de61c",
  "b5bfb1a8-38b2-499a-9a50-8c2aeea90003",
  "5eb62668-7631-11e4-a3cb-005056011aef",
  "c4774e0d-bdd4-430e-abbf-b37a26e1b6ee",
  "5f5bf416-7631-11e4-a3cb-005056011aef",
  "5f5c17f7-7631-11e4-a3cb-005056011aef",
  "5f5c58c7-7631-11e4-a3cb-005056011aef",
  "5f5c105a-7631-11e4-a3cb-005056011aef",
  "5f5c57cd-7631-11e4-a3cb-005056011aef",
  "5f5c1ce3-7631-11e4-a3cb-005056011aef",
  "5f5c1ee6-7631-11e4-a3cb-005056011aef",
  "5f5c1e9c-7631-11e4-a3cb-005056011aef",
  "5f5c1151-7631-11e4-a3cb-005056011aef",
  "5f5c262b-7631-11e4-a3cb-005056011aef",
  "5f5c6a7c-7631-11e4-a3cb-005056011aef",
  "5f5c5c21-7631-11e4-a3cb-005056011aef",
  "5f5c686d-7631-11e4-a3cb-005056011aef",
  "5f5c1f31-7631-11e4-a3cb-005056011aef",
  "5f5c1f79-7631-11e4-a3cb-005056011aef",
  "5f5c5940-7631-11e4-a3cb-005056011aef",
  "5f5c5d16-7631-11e4-a3cb-005056011aef",
  "5f5c2cd9-7631-11e4-a3cb-005056011aef",
  "5f5c12bf-7631-11e4-a3cb-005056011aef",
  "5f5c5fd3-7631-11e4-a3cb-005056011aef",
  "5f5c6904-7631-11e4-a3cb-005056011aef",
  "5f5c11cc-7631-11e4-a3cb-005056011aef",
  "5f5c1c07-7631-11e4-a3cb-005056011aef",
  "5f5c5d91-7631-11e4-a3cb-005056011aef",
  "5f5c2591-7631-11e4-a3cb-005056011aef",
  "5f5c6a32-7631-11e4-a3cb-005056011aef",
  "5f5c2132-7631-11e4-a3cb-005056011aef",
  "5f5c584b-7631-11e4-a3cb-005056011aef",
  "5f5c709f-7631-11e4-a3cb-005056011aef",
  "db747867-eb79-4ecd-ae62-5e00333f2406",
  "5f554924-7631-11e4-a3cb-005056011aef",
  "aa4fbd4b-a63e-4aa3-b2d8-760ab8338fba",
  "5fddfb67-7631-11e4-a3cb-005056011aef",
  "5f5c2e9e-7631-11e4-a3cb-005056011aef",
  "23ab42cd-b029-4707-956e-a3ab4909ca73",
  "5dbc7fa5-7631-11e4-a3cb-005056011aef",
  "5fec2f97-7631-11e4-a3cb-005056011aef",
  "5eb85066-7631-11e4-a3cb-005056011aef",
  "5eb85018-7631-11e4-a3cb-005056011aef",
  "5c8406ce-7631-11e4-a3cb-005056011aef",
  "f51e1100-fbe5-4f6a-b392-ec06be92d5d7",
  "5faa4d04-7631-11e4-a3cb-005056011aef",
  "5ee5636d-7631-11e4-a3cb-005056011aef",
  "6031387e-7631-11e4-a3cb-005056011aef",
  "5f5bf621-7631-11e4-a3cb-005056011aef",
  "5f5c1e0a-7631-11e4-a3cb-005056011aef",
  "5f5c10d6-7631-11e4-a3cb-005056011aef",
  "5f5c5e0a-7631-11e4-a3cb-005056011aef",
  "1c4aab47-b8f1-467a-826d-173c309af5d3",
  "5f5ba3fe-7631-11e4-a3cb-005056011aef",
  "5f5bf92f-7631-11e4-a3cb-005056011aef",
  "5f5c26c3-7631-11e4-a3cb-005056011aef",
  "5f5c6e95-7631-11e4-a3cb-005056011aef",
  "049ac65a-18a0-4478-a74d-21c26e42f500",
  "5eb7c9b2-7631-11e4-a3cb-005056011aef",
]

documents = Document.where(content_id: content_ids)

documents.find_each do |document|
  edition = document.published_edition

  if edition.respond_to?(:attachments)
    edition.attachments.each do |attachment|
      if attachment.attachment_data
        AssetManagerAttachmentMetadataWorker.new.perform(attachment.attachment_data.id)
      end
    end
  end

  PublishingApiDocumentRepublishingWorker.new.perform(document.id)
end
