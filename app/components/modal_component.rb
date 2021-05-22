# frozen_string_literal: true

class ModalComponent < ApplicationComponent
  def initialize(title: "Covidliste", modal_id: nil, class_names: nil, data_attrs: nil)
    @title = title.presence
    @modal_id = modal_id
    @class_names = class_names
    @data_attrs = data_attrs
  end
end
