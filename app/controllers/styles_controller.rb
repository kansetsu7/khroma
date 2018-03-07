class StylesController < ApplicationController

  def index
    @type = Type.find(params[:type_id])
    @styles = @type.styles
  end

end
