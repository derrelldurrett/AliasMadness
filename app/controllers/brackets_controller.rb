class BracketsController < ApplicationController
  def edit
    @bracket ||= Bracket.find(params[:id])
  end

  def show
    @bracket ||= Bracket.find(params[:id])
  end
end
