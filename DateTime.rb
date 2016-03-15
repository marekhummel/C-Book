#Extend the DateTime class to access single properties easier

class DateTime

    def year    
        return self.strftime("%Y").to_i
    end

    def month
        return self.strftime("%m").to_i
    end

    def day
        return self.strftime("%d").to_i
    end

    def hours
        return self.strftime("%H").to_i
    end

    def minutes
        return self.strftime("%M").to_i
    end



    def day_of_the_week
        i = self.strftime("%w").to_i
        days = ["Sonntag", "Montag", "Dienstag", "MIttwoch", "Donnerstag", "Freitag", "Samstag"]

        return days[i]
    end



    def full_date
        return self.day_of_the_week + ", " + self.strftime("%d.%m.%Y")
    end

    def full_time 
        return self.strftime("%H:%M") + " Uhr"
    end

    def format!
       return self.full_date + ", " + self.full_time 
    end

end 