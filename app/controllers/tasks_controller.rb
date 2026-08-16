class TasksController < ApplicationController
  def index
    @tasks = Task.order(completed: :asc, created_at: :desc)
  end

  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        # Use order here! It doesn't cause duplicates, it just keeps your data organized.
        @tasks = Task.order(completed: :asc, created_at: :desc)

        format.turbo_stream # Success: append task and clear form
        format.html { redirect_to tasks_url, notice: "Task was created." }
      else
        # FAILED! (Because the model validation above caught a duplicate)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("new_task_form", partial: "inline_form", locals: { task: @task })
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    @task = Task.find(params[:id])
    # Flip the status from true to false or false to true
    @task.update(completed: !@task.completed)

    # We need all tasks to recalculate the banner counts
    @tasks = Task.order(completed: :asc, created_at: :desc)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    @tasks = Task.order(completed: :asc, created_at: :desc) # We need the new count for the banner!

    respond_to do |format|
      format.turbo_stream # Tells Rails to look for destroy.turbo_stream.erb
      format.html { redirect_to tasks_url, notice: "Task was successfully destroyed." }
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :completed)
  end
end
