require 'test_helper'

class VisualizationsControllerTest < ActionController::TestCase
  setup do
    @visualization = visualizations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:visualizations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create visualization" do
    assert_difference('Visualization.count') do
      post :create, visualization: { caption: @visualization.caption, datum_id: @visualization.datum_id, selections: @visualization.selections, title: @visualization.title, type: @visualization.type }
    end

    assert_redirected_to visualization_path(assigns(:visualization))
  end

  test "should show visualization" do
    get :show, id: @visualization
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @visualization
    assert_response :success
  end

  test "should update visualization" do
    patch :update, id: @visualization, visualization: { caption: @visualization.caption, datum_id: @visualization.datum_id, selections: @visualization.selections, title: @visualization.title, type: @visualization.type }
    assert_redirected_to visualization_path(assigns(:visualization))
  end

  test "should destroy visualization" do
    assert_difference('Visualization.count', -1) do
      delete :destroy, id: @visualization
    end

    assert_redirected_to visualizations_path
  end
end
