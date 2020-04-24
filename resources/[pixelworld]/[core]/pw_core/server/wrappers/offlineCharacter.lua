
function generateOfflineDetails(cid)
    if cid then
        local self = {}
        self.cid = cid

        self.query = MySQL.Sync.fetchAll("SELECT * FROM `characters` WHERE `cid` = @cid", {['@cid'] = self.cid})[1] or nil

        if self.query ~= nil then
            rTable = {}

        -- Basic Information Regarding Character

        rTable.getCID = function()
            return self.cid
        end

        rTable.getCash = function()
            return self.query.cash
        end

        rTable.getFirstName = function()
            return self.query.firstname
        end

        rTable.getLastName = function()
            return self.query.lastname
        end

        rTable.getFullName = function()
            return self.query.firstname..' '..self.query.lastname
        end

        rTable.getEmail = function()
            return self.query.email
        end

        rTable.getTwitter = function()
            return self.query.twitter
        end

        rTable.getDob = function()
            return self.query.dateOfBirth
        end

        rTable.getBio = function()
            return self.query.biography
        end

        rTable.getHealth = function()
            return self.query.getHealth
        end

        rTable.getLastOutfit = function()
            return self.query.cur_outfit
        end

        rTable.setLastOutfit = function(id)
            self.query.cur_outfit = id
        end

        rTable.getSex = function()
            return self.query.sex
        end

        rTable.getJob = function()
            return json.decode(self.query.job)
        end

        rTable.newCharacterCheck = function()
            return self.query.newCharacter
        end

        rTable.Custody = function()
            local custody = {}

            custody.getPrisonState = function()
                local theTable
                
                if self.query.jailed == nil then
                    theTable = { ['inPrison'] = false, ['time'] = 0, ['total'] = 0 }
                else
                    theTable = json.decode(self.query.jailed)
                end

                return theTable
            end

            return custody
        end

        rTable.Health = function()
            local health = {}

            health.getHealth = function(cb)
                local getHealth = MySQL.Sync.fetchScalar("SELECT `health` FROM `characters` WHERE `cid` = @cid", {['@cid'] = self.cid})
                return (getHealth or 200)
            end

            health.getInjuries = function()
                local processed = false
                local info = {}
                MySQL.Async.fetchScalar("SELECT `injuries` FROM `characters` WHERE `cid` = @cid", {['@cid'] = self.cid}, function(inj)
                    if inj ~= nil then
                        info = json.decode(inj)
                        processed = true
                    end
                end)
                repeat Wait(0) until processed == true
                return info
            end

            return health
        end

        rTable.Job = function()
            local job = {}
            local jobData = json.decode(self.query.job)
            job.getJob = function()
                return jobData
            end

            job.setJob = function(job, grade, workplace, salery)
                MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs` WHERE `name` = @job", {['@job'] = job}, function(ajob)
                    if ajob[1] ~= nil then
                        MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = ajob[1].name, ['@grade'] = grade}, function(agrade)
                            if agrade[1] ~= nil then
                                local temp = { ['name'] = jobData.name, ['grade'] = jobData.grade, ['salery'] = jobData.name, ['workplace'] = jobData.workplace, ['duty'] = jobData.duty }
                                jobData.name = ajob[1].name
                                jobData.grade = agrade[1].grade
                                jobData.grade_level = agrade[1].level
                                jobData.salery = (salery or agrade[1].salery)
                                jobData.workplace = workplace
                                jobData.duty = false
                                MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid", {['@cid'] = self.cid, ['@job'] = json.encode(jobData)}, function(done)
                                    if done > 0 then
                                        self.query.job = json.encode(jobData)
                                    else
                                        jobData = temp
                                    end
                                end)
                            end
                        end)
                    end                    
                end)
            end

            job.removeJob = function()
                jobData = Config.NewCharacters.job
                MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid", {['@cid'] = self.cid, ['@job'] = json.encode(jobData)}, function(done)
                    if done > 0 then
                        self.query[1].job = json.encode(jobData)
                    end
                end)
            end

            job.setSalery = function(amt)
                if amt and type(amt) == number then
                    jobData.salery = amt
                    MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid", {['@cid'] = self.cid, ['@job'] = json.encode(jobData)}, function(done)
                        if done > 0 then
                            self.query[1].job = json.encode(jobData)
                        end
                    end)
                end
            end
            
            return job
        end

        return rTable

        end
    end
end