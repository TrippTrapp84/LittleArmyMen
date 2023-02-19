--[=[
    @class StateMachine
]=]
local Handler = {}
Handler.__index = Handler

export type State = string
export type Action = string

--[=[
    @type StateDefinitions
    .[State] : {[Action] : State}
    @within StateMachine
    Describes the structure of data passed to a state machine constructor
]=]
export type StateDefinitions = {
    [State] : {[Action] : State}
}

export type StateChangedCallbackId = {}
export type StateChangedCallback = (CurrentState : State, NewState : State, Action : Action) -> ()

function Handler.new(StateData : StateDefinitions,InitialState : State,InitialAction : Action?)
    local self = setmetatable({},Handler)

    self.CurrentStateId = nil
    self.CurrentState = InitialState
    self.States = {}
    self.Actions = {}
    self.Callbacks = {}
    for State, ActionTable in pairs(StateData) do
        self.States[#self.States+1] = State
    end
    
    self.CurrentStateId = table.find(self.States,self.CurrentState)
    
    for State, ActionTable in pairs(StateData) do
        local StateId = table.find(self.States,State)
        self.Actions[StateId] = {}
        for Action, NewState in pairs(ActionTable) do
            self.Actions[StateId][Action] = table.find(self.States,NewState)
        end
    end

    if InitialAction then
        self:PerformAction(InitialAction)
    end

    return self
end

function Handler:_SetState(NewStateId : number) : (number, State)
    local OldStateId = self.CurrentStateId
    local OldState = self.CurrentState

    self.CurrentStateId = NewStateId
    self.CurrentState = self.States[NewStateId]

    return OldStateId,OldState
end

function Handler:GetState() : (number, State)
    return self.CurrentStateId, self.CurrentState
end

function Handler:PerformAction(Action : Action) : (number, State)
    local NewStateId = self.Actions[self.CurrentStateId][Action]
    local OldStateId, OldState = self:_SetState(NewStateId)

    self:_CallCallbacks(OldStateId,OldState,NewStateId,self.States[NewStateId],Action)

    return self.CurrentStateId, self.CurrentState
end

function Handler:_CallCallbacks(StateId : number,State : State, NewStateId : number, NewState : State,Action : Action)
    for _,Callback in pairs(self.Callbacks) do
        Callback(State,NewState,Action)
    end
end

function Handler:BindCallbackToStateChange(Callback : StateChangedCallback) : StateChangedCallbackId
    local CallbackInd = {}
    self.Callbacks[CallbackInd] = Callback
    return CallbackInd
end

function Handler:UnbindCallback(CallbackId : StateChangedCallbackId)
    self.Callbacks[CallbackId] = nil
end

return Handler