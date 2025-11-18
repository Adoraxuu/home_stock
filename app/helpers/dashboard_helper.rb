module DashboardHelper
  def movement_type_badge_class(type)
    case type
    when "add"
      "bg-[var(--color-sage-100)] text-[var(--color-sage-600)]"
    when "remove"
      "bg-[var(--color-accent-100)] text-[var(--color-accent-700)]"
    when "set"
      "bg-[var(--color-primary-100)] text-[var(--color-primary-600)]"
    when "adjust"
      "bg-[var(--color-secondary-100)] text-[var(--color-secondary-600)]"
    else
      "bg-[var(--color-neutral-100)] text-[var(--color-neutral-600)]"
    end
  end

  def movement_type_label(type)
    case type
    when "add" then "新增"
    when "remove" then "減少"
    when "set" then "設定"
    when "adjust" then "調整"
    else type
    end
  end
end
