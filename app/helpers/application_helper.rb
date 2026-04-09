module ApplicationHelper
  def field_classes(employee, attr)
    base = "block w-full rounded-lg border px-3 py-2 mt-1 text-slate-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/50"
    employee.errors[attr].any? ? "#{base} border-red-400" : "#{base} border-slate-300"
  end
end
