#Extend the DateTime class to access single properties easier

class DateTime

    def Year    
        return self.strftime("%Y").to_i
    end

    def Month
        return self.strftime("%m").to_i
    end

    def Day
        return self.strftime("%d").to_i
    end

    def Hours
        return self.strftime("%H").to_i
    end

    def Minutes
        return self.strftime("%M").to_i
    end

    def Seconds
        return self.strftime("%S").to_i
    end

    def DayOfTheWeek
        i = self.strftime("%w").to_i
        days = ["Sonntag", "Montag", "Dienstag", "MIttwoch", "Donnerstag", "Freitag", "Samstag"]

        return days[i]
    end



    def FullDate
        return self.DayOfTheWeek + ", " + self.strftime("%d.%m.%Y")
    end

    def FullTime 
        return self.strftime("%H:%M") + " Uhr"
    end

    def Format!
       return self.FullDate + ", " + self.FullTime
    end

end 