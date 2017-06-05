package ru.bav.vamp.controllers.units {
    import ru.bav.vamp.controllers.units.*;
    import ru.bav.vamp.models.consts.*;
    import ru.bav.vamp.events.*;
    import ru.bav.vamp.models.MainModel;
    import ru.bav.vamp.models.MapCellModel;
    import ru.bav.vamp.models.UnitModel;
    import ru.bav.vamp.views.units.UnitViewBase;
    import ru.bav.vamp.views.MapCeilView;
    import flash.events.TimerEvent;
	
	/**
     * Policeman controller.
     * @author bav
     */
    public class PolicemanController extends NPCController {
        
        public function PolicemanController(model:MainModel, unitInfo:UnitModel, view:UnitViewBase) {
            super(model, unitInfo, view);
        }
    }
}
