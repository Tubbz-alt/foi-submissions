# frozen_string_literal: true

module Foi
  ##
  # This controller is responsible for creating and updating contact details of
  # a FOI requester.
  #
  class ContactsController < ApplicationController
    include FindableFoiRequest

    before_action :redirect_to_contact, :new_contact, only: %i[new create]
    def new; end

    def create
      if @contact.update(contact_params)
        redirect_to foi_request_preview_path(@foi_request)
      else
        render :new
      end
    end

    def edit; end

    def update; end

    private

    def redirect_to_contact
      return unless @foi_request.contact
      redirect_to edit_foi_request_contact_path(@foi_request)
    end

    def new_contact
      @contact = @foi_request.build_contact
    end

    def contact_params
      params.require(:contact).permit(:full_name, :email)
    end
  end
end
