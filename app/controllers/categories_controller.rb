class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ edit update destroy ]

  def index
    @categories = Current.user.categories.order(:name)
  end

  def new
    @category = Current.user.categories.new
  end

  def edit
  end

  def create
    @category = Current.user.categories.new(category_params)

    if @category.save
      redirect_to categories_path, notice: "Category was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Category was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @category.destroy!
    redirect_to categories_path, notice: "Category was successfully destroyed.", status: :see_other
  end

  private
    def set_category
      @category = Current.user.categories.find(params.expect(:id))
    end

    def category_params
      params.expect(category: [ :name ])
    end
end
