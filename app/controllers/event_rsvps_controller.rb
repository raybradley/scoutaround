class EventRsvpsController < EventContextController
  before_action :find_rsvp, except: [:index, :new, :create, :create_batch]

  def create
    event_rsvp_params = params[:event_rsvp].permit(:unit_membership_id, :response)
    event_rsvp_params[:respondent] = @current_member
    @rsvp = @event.rsvps.find_or_create_by!(event_rsvp_params)
  end

  def create_batch
    params[:unit_memberships].each do |member_id, rsvp_attributes|
      rsvp = @event.rsvps.find_or_initialize_by(unit_membership_id: member_id.to_i)
      rsvp.respondent = @current_member
      rsvp.response = rsvp_attributes[:response]
      rsvp.note = params[:note]
      rsvp.save if rsvp.changed?
    end

    redirect_to [@unit, @event], notice: "Your RSVPs been received."
  end

  def edit; end

  def update
    if params[:event_rsvp][:response] == "delete"
      @rsvp.destroy
    else
      @rsvp.update(params[:event_rsvp].permit(:unit_membership_id, :response))
    end
  end

  def new
    @rsvp = @event.rsvps.new(unit_membership_id: params[:unit_membership_id])
  end

  def destroy
    authorize @rsvp
    event = @rsvp.event
    display_name = @rsvp.full_display_name
    @rsvp.destroy
    redirect_to unit_event_rsvps_path(@unit, event),
                notice: I18n.t("events.organize.confirmations.delete", name: display_name)
  end

  private

  def find_rsvp
    @rsvp = EventRsvp.find(params[:id])
  end

  def find_event
    @event = @unit.events.find(params[:event_id])
  end

  def find_unit
    @unit = Unit.find(params[:unit_id])
  end

  def find_event_responses
    @non_respondents = @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
  end
end
