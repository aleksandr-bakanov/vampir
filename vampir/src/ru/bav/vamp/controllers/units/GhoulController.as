package ru.bav.vamp.controllers.units {
    import ru.bav.vamp.models.*;
    import ru.bav.vamp.views.units.*;
    
	/**
     * Ghoul controller
     * @author bav
     */
    public class GhoulController extends NPCController {
        
        public function GhoulController(model:MainModel, unitInfo:UnitModel, view:UnitViewBase) {
            super(model, unitInfo, view);
        }
    }
}
