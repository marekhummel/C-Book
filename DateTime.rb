#Extend the DateTime class to access single properties easier

class DateTime

    def Year    
        self.strftime("%Y").to_i
    end

    def Month
        self.strftime("%m").to_i
    end

    def Day
        self.strftime("%d").to_i
    end

    def Hours
        self.strftime("%H").to_i
    end

    def Minutes
        self.strftime("%M").to_i
    end

    def Seconds
        self.strftime("%S").to_i
    end

end 